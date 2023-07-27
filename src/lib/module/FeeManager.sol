// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ModuleFee} from "./ModuleFee.sol";

/// @title Station Network Fee Manager Contract
/// @author 👦🏻👦🏻.eth

/// @dev This contract stores state for all fees set on both a one-size fits all default basis and per-collection basis
/// Handles fee calculations when called by modules inquiring about the total fees involved in a mint, including ERC20 support and Station discounts

/// @notice todo This implementation is currently a standalone contract but will be converted to a UUPS proxy, removing constructor() and using initialize()

contract FeeManager is Ownable {

    /// @dev Struct of fee data, including both the base and variable fees
    /// @param baseFee The flat fee charged by Station Network on a per item basis
    /// @param variableFee The variable fee (in BPS) charged by Station Network on volume basis
    /// Accounts for each item's cost and total amount of items

    struct Fees {
        uint128 baseFee;
        uint128 variableFee;
    }

    /*============
        ERRORS
    ============*/

    /// @dev Throws when supplied fees to be set are lower than the bpsDenominator to prevent Solidity rounding to 0
    error insufficientVariableFee();
    error FeeCollectFailed();

    /*============
        EVENTS
    ============*/

    event FeeUpdated(Fees);

    /*=============
        STORAGE
    =============*/

    /// @dev Denominator used to calculate variable fee on a BPS basis
    /// @dev Not actually kept in storage as it is marked `constant`, saving gas by putting its value in contract bytecode instead
    uint256 constant private bpsDenominator = 10_000;

    /// @dev Baseline fee struct that serves as a stand in for all token addresses that have been registered
    /// in a stablecoin purchase module but not had their default fees set
    Fees baselineFees;

    /// @dev Mapping that stores default fees associated with a given token address
    mapping (address => Fees) public defaultFees;

    /// @dev Mapping that stores override fees associated with specific collections, ie for discounts
    mapping (address => mapping (address => Fees)) internal overrideFees;

    /*=================
        FEEMANAGER
    =================*/

    /// @notice Constructor will be deprecated in favor of an initialize() UUPS proxy call once logic is finalized & approved
    /// @param _newOwner The initialization of the contract's owner address, managed by Station
    /// @param _baselineFees The initialization of baseline fees for all token addresses that have not (yet) been given defaults
    /// @param _ethDefaultFees The initialization of ETH (or MATIC etc)'s default fees in wei
    constructor(address _newOwner, Fees memory _baselineFees, Fees memory _ethDefaultFees) {
        baselineFees = _baselineFees;
        _isSufficientVariableFee(_ethDefaultFees);
        defaultFees[address(0x0)] = _ethDefaultFees;
        _transferOwnership(_newOwner);
    }


    /// @dev Function to set default base and variable fees across all collections without specified overrides
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param token The token for which to set new base and variable fees
    /// @param newDefaultFees The new Fees struct to set in storage
    function setDefaultFees(address token, Fees calldata newDefaultFees) external onlyOwner {
        _isSufficientVariableFee(newDefaultFees);
        defaultFees[token] = newDefaultFees;
    }

    /// @dev Function to set override base and variable fees on a per-collection basis
    /// @param collection The collection for which to set override fees
    /// @param token The token for which to set new base and variable fees
    /// @param newOverrideFees The new Fees struct to set in storage
    function setOverrideFees(address collection, address token, Fees calldata newOverrideFees) external onlyOwner {
        _isSufficientVariableFee(newOverrideFees);
        overrideFees[collection][token] = newOverrideFees;
    }

    /// @dev Reverts fee updates when variableFees are nonzero but less than the bpsDenominator constant.
    /// @dev Prevents Solidity's arithmetic functionality from rounding a nonzero fee value to zero when not desired
    function _isSufficientVariableFee(Fees memory newFees) internal pure {
        // prevent Solidity arithmetic rounding to 0 when not intended
        if (newFees.variableFee != 0 && newFees.variableFee < bpsDenominator) revert insufficientVariableFee();
    }

    /*============
        VIEWS
    ============*/

    /// @dev Function to get collection fees
    /// @param collection The collection whose fees will be read, including checks for client-specific fee discounts
    /// @param paymentToken The ERC20 token address used to pay fees. Will use base currency (ETH, MATIC, etc) when == address(0)
    /// @param recipient The address to mint to. Checked to apply discounts per user for Station Network incentives
    /// @param quantity The amount of tokens for which to compute total baseFee
    /// @param unitPrice The price of each token, used to compute subtotal on which to apply variableFee
    /// @param feeTotal The returned total incl fees for the given collection. 
    function getFeeTotals(
        address collection, 
        address paymentToken,
        address recipient,
        uint256 quantity, 
        uint256 unitPrice
    ) external view returns (uint256 feeTotal) {
        // todo handle recipient discounts for individual users holding a collection NFT
        
        // get existing fees, first checking for override fees or discounts if they have already been set
        Fees memory existingFees = _checkOverrideFees(collection, paymentToken);

        // check if being called in free mint context, which results in only ETH base fee
        if (unitPrice == 0) {
            (uint256 baseFeeTotal,) = _calculateFees(
                existingFees.baseFee,
                existingFees.variableFee,
                quantity,
                0
            );
            return baseFeeTotal;
        } else {
        // otherwise agnostically calculate fees
            (uint256 baseFeeTotal, uint256 variableFeeTotal) =  _calculateFees(
                existingFees.baseFee, 
                existingFees.variableFee, 
                quantity, 
                unitPrice
            );
            return baseFeeTotal + variableFeeTotal;
        }
    }

    /*============
        UTILS
    ============*/

    /// @dev Function to calculate fees using base and variable fee structures, agnostic to ETH or ERC20 values
    /// @param baseFee The base fee denominated either in ETH or ERC20 tokens
    /// @param variableFee The variable fee denominated either in ETH or ERC20 tokens
    /// @param quantity The number of tokens being minted
    /// @param unitPrice The price per unit of tokens being minted
    function _calculateFees(
        uint256 baseFee,
        uint256 variableFee,
        uint256 quantity, 
        uint256 unitPrice
    ) internal pure returns (uint256 baseFeeTotal, uint256 variableFeeTotal) {
        // calculate baseFee total (quantity * unitPrice), set to baseFee
        baseFeeTotal = quantity * baseFee;
        // apply variable fee on baseFee total, set to variableFee
        variableFeeTotal = unitPrice * quantity * variableFee / bpsDenominator;
    }

    /// @dev Function to evaluate whether override fees have been set for a specific collection 
    /// and whether default fees have been set for the given token
    function _checkOverrideFees(
        address _collection,
        address _token
    ) internal view returns (Fees memory existingFees) {
        // cache storage struct in memory to save SLOAD reads
        Fees memory overrides = overrideFees[_collection][_token];
        // check for any existing fee overrides, returning defaults if none are set
        bool overridesExist = overrides.baseFee != 0 || overrides.variableFee != 0;
       
        if (overridesExist) {
            existingFees = overrides;
        } else {
            Fees memory defaults = defaultFees[_token];
            bool defaultsExist = defaults.baseFee != 0 || defaults.variableFee != 0;
           
            if (defaultsExist) {
                existingFees = defaults;
            } else existingFees = baselineFees;
        }
    }
}
