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
    /// @param zeroFee A quasi-Boolean value indicating whether the collection is a free mint. 1 represents `false` and 2 represents `true`
    /// 8 byte unsigned integers 1 || 2 are utilized instead of 0 || 1 for two reasons: 
    /// 1. Provide a quantifiable, nonzero indication that a collection exists and has been registered with Station by an authorized Module
    /// 2. Save gas on initialization costs when setting a cold storage slot from 0 to 1. Can also be packed if need for future struct members arises
    /// @param baseFee The flat fee charged by Station Network on a per item basis
    /// @param variableFee The variable fee (in BPS) charged by Station Network on volume basis
    /// Accounts for each item's cost and total amount of items

    struct Fees {
        uint8 zeroFee;
        uint128 baseFee;
        uint128 variableFee;
    }

    /*============
        ERRORS
    ============*/

    /// @dev Throws when supplied fees to be set are lower than the bpsDenominator to prevent Solidity rounding to 0
    error InsufficientVariableFee();
    error FeeCollectFailed();

    /*============
        EVENTS
    ============*/

    event BaselineFeeUpdated(Fees fees);
    event DefaultFeeUpdated(address indexed token, Fees fees);
    event OverrideFeeUpdated(address indexed collection, address indexed token, Fees fees);

    /*=============
        STORAGE
    =============*/

    /// @dev Denominator used to calculate variable fee on a BPS basis
    /// @dev Not actually kept in storage as it is marked `constant`, saving gas by putting its value in contract bytecode instead
    uint256 constant private bpsDenominator = 10_000;

    /// @dev Baseline fee struct that serves as a stand in for all token addresses that have been registered
    /// in a stablecoin purchase module but not had their default fees set
    Fees public baselineFees;

    /// @dev Mapping that stores default fees associated with a given token address
    mapping (address => Fees) internal defaultFees;

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
        require(
            (_baselineFees.zeroFee == 1 || _baselineFees.zeroFee == 2)
            && (_ethDefaultFees.zeroFee == 1 || _ethDefaultFees.zeroFee == 2), 
            "INVALID_ZEROFEE_BOOL"
        );
        baselineFees = _baselineFees;
        _isSufficientVariableFee(_ethDefaultFees);
        defaultFees[address(0x0)] = _ethDefaultFees;
        _transferOwnership(_newOwner);

        emit BaselineFeeUpdated(_baselineFees);
        emit DefaultFeeUpdated(address(0x0), _ethDefaultFees);
    }


    /// @dev Function to set baseline base and variable fees across all collections without specified defaults
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param newBaselineFees The new Fees struct to set in storage
    function setBaselineFees(Fees memory newBaselineFees) external onlyOwner {
        require(newBaselineFees.zeroFee == 1 || newBaselineFees.zeroFee == 2, "INVALID_ZEROFEE_BOOL");
        baselineFees = newBaselineFees;

        emit BaselineFeeUpdated(newBaselineFees);
    }

    /// @dev Function to set default base and variable fees across all collections without specified overrides
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param token The token for which to set new base and variable fees
    /// @param newDefaultFees The new Fees struct to set in storage
    function setDefaultFees(address token, Fees calldata newDefaultFees) external onlyOwner {
        require(newDefaultFees.zeroFee == 1 || newDefaultFees.zeroFee == 2, "INVALID_ZEROFEE_BOOL");
        _isSufficientVariableFee(newDefaultFees);
        defaultFees[token] = newDefaultFees;

        emit DefaultFeeUpdated(token, newDefaultFees);
    }

    /// @dev Function to set override base and variable fees on a per-collection basis
    /// @param collection The collection for which to set override fees
    /// @param token The token for which to set new base and variable fees
    /// @param newOverrideFees The new Fees struct to set in storage
    function setOverrideFees(address collection, address token, Fees calldata newOverrideFees) external onlyOwner {
        require(newOverrideFees.zeroFee == 1 || newOverrideFees.zeroFee == 2, "INVALID_ZEROFEE_BOOL");
        _isSufficientVariableFee(newOverrideFees);
        overrideFees[collection][token] = newOverrideFees;

        emit OverrideFeeUpdated(collection, token, newOverrideFees);
    }

    /// @dev Reverts fee updates when variableFees are nonzero but less than the bpsDenominator constant.
    /// @dev Prevents Solidity's arithmetic functionality from rounding a nonzero fee value to zero when not desired
    function _isSufficientVariableFee(Fees memory newFees) internal pure {
        // prevent Solidity arithmetic rounding to 0 when not intended
        if (newFees.variableFee != 0 && newFees.variableFee < bpsDenominator) revert InsufficientVariableFee();
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
            (uint256 baseFeeTotal, uint256 variableFeeTotal) =  _calculateFees(
                existingFees.baseFee, 
                existingFees.variableFee, 
                quantity, 
                unitPrice
            );
            return baseFeeTotal + variableFeeTotal;
        }
    }

    /// @dev Function to get default fees for a token if they have been set
    /// @param token The token address to query against defaultFees mapping
    function getDefaultFees(address token) public view returns (Fees memory tokenDefaults) {
        tokenDefaults = defaultFees[token];
        require(tokenDefaults.zeroFee != 0, "UNSUPPORTED_TOKEN");
    }

    /// @dev Function to get override fees for a collection and token if they have been set
    /// @param collection The collection address to query against overrideFees mapping
    /// @param token The token address to query against overrideFees mapping
    function getOverrideFees(address collection, address token) public view returns (Fees memory overrides) {
        overrides = overrideFees[collection][token];
        require(overrides.zeroFee != 0, "UNSET_OVERRIDES");
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

        // check if zeroFee is set, indicating existing fee overrides or defaults, otherwise return baseline fees
        bool overridesExist = overrides.zeroFee != 0;

        if (overridesExist) { 
            existingFees = overrides; 
        } else {
            Fees memory defaults = defaultFees[_token];
            bool defaultsExist = defaults.zeroFee != 0;

            if (defaultsExist) {
                existingFees = defaults;
            } else existingFees = baselineFees;
        }
    }
}
