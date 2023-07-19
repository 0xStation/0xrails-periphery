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
    /// @param baseFee The flat fee charged by Station Network on a per item basis, in ETH
    /// @param variableFee The variable fee (in BPS) charged by Station Network on volume basis, accounting for each item's cost and total amount of items
    /// @param enabledStables A bitmap of single byte keys that correspond to supported stablecoins
    struct Fees {
        uint256 baseFee;
        uint256 variableFee;
        bytes16 enabledStables;
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
    error InsufficientFee();

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
        _isSufficientFee(initialDefaultFees);
        defaultFees = initialDefaultFees;
        _transferOwnership(newOwner);
    }

    /// @dev Function to set default base and variable fees across all collections without specified overrides
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param newDefaultFees The new Fees struct to set in storage
    function setDefaultFees(Fees calldata newDefaultFees) external onlyOwner {
        _isSufficientFee(newDefaultFees);

        defaultFees.baseFee = newDefaultFees.baseFee;
        defaultFees.variableFee = newDefaultFees.variableFee;
    }

    /// @dev Function to set override base and variable fees on a per-collection basis
    /// @dev Uses _checkForDuplicateFee() to potentially save gas on a redundant SSTORE opcode
    /// @param collection The collection for which to set override fees
    /// @param newOverrideFees The new Fees struct to set in storage
    function setOverrideFees(address collection, Fees calldata newOverrideFees) external onlyOwner {
        _isSufficientFee(newOverrideFees);

        // check if one or more override fees have been set for the provided collection
        if (overrideFees[collection].baseFee != 0 || overrideFees[collection].variableFee != 0) {
            Fees memory processedFees = _checkForDuplicateFees(collection, newOverrideFees.baseFee, newOverrideFees.variableFee);
            // write fees to storage only if they have been determined not to be a duplicate
            if (processedFees.baseFee != 0) overrideFees[collection].baseFee = processedFees.baseFee;
            if (processedFees.variableFee != 0) overrideFees[collection].variableFee = processedFees.variableFee;
        } else {
            overrideFees[collection] = newOverrideFees;
        }
    }

    
    ///todo
    /// @dev Function to enable desired stablecoins supported by a collection
    // function setEnabledStables(bytes16 newStables) external onlyOwner {}

    /// @dev Checks for redundant override fee updates to save 100 gas on an unnecessary warm SSTORE opcode in case only one fee type is altered
    /// @dev Executes two cold SSTOREs if no duplicates found versus two cold SLOADs + one warm SSTORE if duplicate is found (4400 vs 4300)
    function _checkForDuplicateFees(
        address _collection, 
        uint256 _newBaseFee, 
        uint256 _newVariableFee
    ) internal view returns (Fees memory processedFees) {
        // only set return values if not a duplicate
        if (overrideFees[_collection].baseFee != _newBaseFee) {
            processedFees.baseFee = _newBaseFee;
        }
        if (overrideFees[_collection].variableFee != _newVariableFee) {
            processedFees.variableFee = _newVariableFee;
        }
    }

    /// @dev Reverts fee updates when baseFee and variableFees are nonzero but less than the bpsDenominator constant.
    /// @dev Prevents Solidity's arithmetic functionality from rounding a nonzero fee value to zero when not desired
    function _isSufficientFee(Fees memory newFees) internal view {
        // prevent Solidity arithmetic rounding to 0 when not intended
        if (newFees.baseFee != 0 && newFees.baseFee < bpsDenominator || newFees.variableFee != 0 && newFees.variableFee < bpsDenominator) {
            revert InsufficientFee();
        }
    }

    /*============
        VIEWS
    ============*/

    /// @dev Function to get collection fees
    /// @param collection The collection whose fees will be read, including checks for client-specific fee discounts
    /// @param paymentToken The ERC20 token address used to pay fees. Will use base currency (ETH, MATIC, etc) when == address(0)
    /// @param quantity The amount of tokens for which to compute total baseFee
    /// @param unitPrice The price of each token, used to compute subtotal on which to apply variableFee
    /// @param recipient The address checked to apply discounts per user for Station Network incentives
    /// @param feeTotals The returned fee totals for the given collection. Will be summed together by the ModuleFeesV2 contract
    /// @notice todo: add support for multiple collections in single call
    function getFeeTotals(
        address collection, 
        address paymentToken, 
        uint256 quantity, 
        uint256 unitPrice, 
        address recipient
    ) external view returns (Fees memory feeTotals) {
        // todo check that collection exists and has been registered
        // todo check if collection has existing discount
        // todo handle recipient discounts for individual users holding a collection NFT
        // check if override fees have already been set for provided collection
        Fees memory existingFees;
        if (overrideFees[collection].baseFee != 0 || overrideFees[collection].variableFee != 0) {
            existingFees = overrideFees[collection];
        } else {
            existingFees = defaultFees;
        }
        // check if paymentToken == address(0) and take _calculateFeesEth() or _ calculateFeesERC20() path accordingly
        if (paymentToken == address(0)) {
            feeTotals =  _calculateFeesEth(existingFees, quantity, unitPrice);
        } else {
            feeTotals = _calculateFeesERC20(existingFees, quantity, unitPrice);
        }
    }

    function _calculateFeesEth(
        Fees memory existingFees, 
        uint256 quantity, 
        uint256 unitPrice
    ) internal pure returns (Fees memory feeTotals) {
        // calculate baseFee total (quantity * unitPrice), set to feeTotals.baseFee
        feeTotals.baseFee = quantity * existingFees.baseFee;
        // apply variable fee on baseFee total, set to feeTotals.variableFee
        feeTotals.variableFee = unitPrice * quantity * existingFees.variableFee / bpsDenominator;
    }

    //todo
    function _calculateFeesERC20(
        Fees memory existingFees, 
        uint256 quantity, 
        uint256 unitPrice
    ) internal pure returns (Fees memory feeTotals) {}
}