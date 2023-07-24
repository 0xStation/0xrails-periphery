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
    /// @param ethBaseFee The flat fee charged by Station Network on a per item basis, in ETH
    /// @param ethVariableFee The variable fee (in BPS) charged by Station Network on volume basis
    /// Accounts for each item's cost and total amount of items, in ETH
    /// @param erc20BaseFee The flat fee charged by Station Network on a per item basis, in ERC20 stablecoins
    /// @param erc20VariableFee The variable fee (in BPS) charged by Station Network on volume basis, accounting for each item's cost and total amount of items
    /// Accounts for each item's cost and total amount of items, in ERC20 stablecoins

    /// @notice TODO Do the math on safety & security implications of packing storage struct members as uint128 instead of uint256 
    struct Fees {
        uint256 ethBaseFee;
        uint256 ethVariableFee;
        uint256 erc20BaseFee;
        uint256 erc20VariableFee;
    }

    /*=============
        STORAGE
    =============*/

    /// @dev Denominator used to calculate variable fee on a BPS basis
    /// @dev Not actually kept in storage as it is marked `constant`, saving gas by putting its value in contract bytecode instead
    uint256 constant private bpsDenominator = 10_000;

    Fees public defaultFees;

    /// @dev Mapping that stores override fees associated with specific collections
    /// @dev Since Station supports batch minting, visibility is set to private with a manual getter function implementation
    /// in order to save gas by using a single getTotalFee() call rather than repeated calls for batch mints
    mapping (address => Fees) internal overrideFees;

    /*============
        ERRORS
    ============*/

    /// @dev Throws when supplied fees to be set are lower than the bpsDenominator to prevent Solidity rounding to 0
    error insufficientVariableFee();

    /*============
        EVENTS
    ============*/

    event FeeUpdated(Fees);

    /*=================
        FEEMANAGER
    =================*/

    /// @notice Constructor will be deprecated in favor of an initialize() UUPS proxy call once logic is finalized & approved
    /// @param newOwner The initialization of the contract's owner address, managed by Station
    /// @param initialDefaultFees The initialization data for the default fees for all collections
    constructor(address newOwner, Fees memory initialDefaultFees) {
        _isSufficientVariableFee(initialDefaultFees);
        defaultFees = initialDefaultFees;
        _transferOwnership(newOwner);
    }

    /// @dev Function to set default base and variable fees across all collections without specified overrides
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param newDefaultFees The new Fees struct to set in storage
    function setDefaultFees(Fees calldata newDefaultFees) external onlyOwner {
        _isSufficientVariableFee(newDefaultFees);

        defaultFees = newDefaultFees;
    }

    /// @dev Function to set override base and variable fees on a per-collection basis
    /// @param collection The collection for which to set override fees
    /// @param newOverrideFees The new Fees struct to set in storage
    function setOverrideFees(address collection, Fees calldata newOverrideFees) external onlyOwner {
        _isSufficientVariableFee(newOverrideFees);
        overrideFees[collection] = newOverrideFees;
    }

    /// @dev Reverts fee updates when variableFees are nonzero but less than the bpsDenominator constant.
    /// @dev Prevents Solidity's arithmetic functionality from rounding a nonzero fee value to zero when not desired
    function _isSufficientVariableFee(Fees memory newFees) internal pure {
        // prevent Solidity arithmetic rounding to 0 when not intended
        if (newFees.ethVariableFee != 0 && newFees.ethVariableFee < bpsDenominator) revert insufficientVariableFee();
        if (newFees.erc20VariableFee != 0 && newFees.erc20VariableFee < bpsDenominator) revert insufficientVariableFee();
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
    /// @param baseFeeTotal The returned base fee total for the given collection. 
    /// Will be summed with variableFeeTotal by the ModuleFeesV2 contract
    /// @param variableFeeTotal The returned variable fee total for the given collection. 
    /// Will be summed with baseFeeTotal by the ModuleFeesV2 contract
    function getFeeTotals(
        address collection, 
        address paymentToken,
        address recipient,
        uint256 quantity, 
        uint256 unitPrice
    ) external view returns (uint256 baseFeeTotal, uint256 variableFeeTotal) {
        // todo check if collection has existing discount
        // todo handle recipient discounts for individual users holding a collection NFT
        
        // get override fees if they have already been set for provided collection, else get defaults
        Fees memory existingFees = _checkOverrideFees(collection);

        // decide whether to collect ETH or ERC20 fees
        if (paymentToken == address(0)) {
            // terminate if being called as a free mint, where only ethBaseFee applies
            if (unitPrice == 0) return (existingFees.ethBaseFee, existingFees.ethVariableFee);

            (baseFeeTotal, variableFeeTotal) =  _calculateFees(
                existingFees.ethBaseFee, 
                existingFees.ethVariableFee, 
                quantity, 
                unitPrice
            );
        } else {
            // terminate if being called as a free mint, where only erc20BaseFee applies
            if (unitPrice == 0) return (existingFees.erc20BaseFee, existingFees.erc20VariableFee);

            (baseFeeTotal, variableFeeTotal) = _calculateFees(
                existingFees.erc20BaseFee, 
                existingFees.erc20VariableFee, 
                quantity, 
                unitPrice
            );
        }
    }

    /*============
        UTILS
    ============*/

    /// @dev Function to calculate fees using base and variable fee structures, agnostic to whether inputs are ETH or ERC20 values
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

    /// @dev Function to evaluate whether override fees have been set for ETH or ERC20 struct members depending on context
    function _checkOverrideFees(
        address _collection
    ) internal view returns (Fees memory existingFees) {
        // cache storage struct in memory to save SLOAD reads
        Fees memory overrides = overrideFees[_collection];
        // check for any existing fee overrides, returning defaults if none are set
        bool overridesExist = overrides.ethBaseFee != 0 
            || overrides.ethVariableFee != 0
            || overrides.erc20BaseFee != 0 
            || overrides.erc20VariableFee != 0;
        
        if (overridesExist) {
            existingFees = overrides;
        } else { 
            existingFees = defaultFees;
        }
    }
}