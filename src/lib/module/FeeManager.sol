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
    struct Fees {
        uint256 baseFee;
        uint256 variableFee;
    }

    /*=============
        STORAGE
    =============*/

    Fees public defaultFees {
        uint256 defaultBaseFee;
        uint256 defaultVariableFee;
    }

    /// @dev Mapping that stores override fees associated with specific collections
    /// @dev Since Station supports batch minting, visibility is set to private with a manual getter function implementation
    /// in order to save substantial gas by using a single getTotalFee() call rather than repeated calls for batch mints
    mapping (address => Fees) internal overrideFees;

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
    constructor(address newOwner, Fees initialDefaultFees) {
        _transferOwnership(newOwner);
        defaultFees = initialDefaultFees;
    }

    /// @dev Function to set default base and variable fees across all collections without specified overrides
    /// @dev Only callable by contract owner, an address managed by Station
    /// @param newDefaultFees The new Fees struct to set in storage
    function setDefaultFees(Fees calldata newDefaultFees) external onlyOwner {
        defaultFees.defaultBaseFee = newDefaultFees.baseFee;
        defaultFees.defaultVariableFee = newDefaultFees.variableFee;
    }

    /// @dev Function to set override base and variable fees on a per-collection basis
    /// @dev Uses _checkForDuplicateFee() to potentially save gas on a redundant SSTORE opcode
    /// @param collection The collection for which to set override fees
    /// @param newOverrideFees The new Fees struct to set in storage
    function setOverrideFees(address collection, Fees calldata newOverrideFees) external onlyOwner {
        // check if one or more override fees have been set for the provided collection
        if (overrideFees[collection].baseFee != 0 || overrideFees[collection].variableFee != 0) {
            Fees memory processedFees = _checkForDuplicateFees(collection, newOverrideFees.baseFee, newOverrideFees.variableFee);
            // write fees to storage only if they have been determined not to be a duplicate
            if (processedFees.baseFee) overrideFees[collection].baseFee = processedFees.baseFee;
            if (processedFees.variableFee) overrideFees[collection].variableFee = processedFees.variableFee;
        } else {
            overrideFees[collection] = newOverrideFees;
        }
    }

    /// @dev Checks for redundant override fee updates to save 100 gas on an unnecessary warm SSTORE opcode in case only one fee type is altered
    /// @dev Executes two cold SSTOREs if no duplicates found versus two cold SLOADs + one warm SSTORE if duplicate is found
    function _checkForDuplicateFees(
        address _collection, 
        uint256 _newBaseFee, 
        uint256 _newVariableFee
    ) internal pure returns (Fees memory processedFees) {
        // only set return values if not a duplicate
        if (overrideFees[_collection].baseFee != _newBaseFee) {
            processedFees.baseFee = _newBaseFee;
        }
        if (overrideFees[_collection].variableFee ! = _newVariableFee) {
            processedFees.variableFee = _newVariableFee;
        }
    }

    /*============
        VIEWS
    ============*/

    // function to get a collection's fees
    /// @param collection The collection whose fees will be read, including checks for client-specific fee discounts
    /// @param paymentToken The ERC20 token address used to pay fees. Will use base currency (ETH, MATIC, etc) when == address(0)
    /// @param quantity The amount of tokens for which to compute total baseFee
    /// @param unitPrice The price of each token, used to compute subtotal on which to apply variableFee
    /// @param recipient The address checked to apply discounts per user for Station Network incentives
    function getFeeTotals(
        address collection, 
        address paymentToken, 
        uint256 quantity, 
        uint256 unitPrice, 
        address recipient
    ) external view returns (Fees feeTotals) {
        //TODO
        // check if override fees have been set for provided collection
        // check if paymentToken == address(0) and take _calculateFeesEth() or _ calculateFeesERC20() path accordingly
        // calculate baseFee total (quantity * unitPrice), set to feeTotals.baseFee
        // apply variable fee on baseFee total, set to feeTotals.variableFee
        // note the above two struct members will need to be added together in the ModuleFeeV2 to get grand total
    }

    //todo
    // function _calculateFeesEth() internal pure returns (uint256 base, uint256 variable) {}
    // function _calculateFeesERC20() internal pure returns (uint256 base, uint256 variable) {}
}