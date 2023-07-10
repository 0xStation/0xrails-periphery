// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {FeeManager} from "./FeeManager.sol";

/// @title Station Network Fee Manager Contract
/// @author 👦🏻👦🏻.eth

/// @dev This contract enables payment by handling funds when charging base and variable fees on each Membership's mints
/// @dev This module should be inherited by all Membership collections that intend to accept payment in either ETH or ERC20 tokens

/// @notice todo This implementation currently only handles ETH, will need to be mixed with (storage-packed) ERC20 logic from FixedStablecoinPurchaseModule.sol
contract ModuleFeeV2 is Ownable {

    /*=============
        STORAGE
    =============*/

    /// @dev Address of the deployed FeeManager contract which stores state for all collections' fee information
    /// @dev The FeeManger serves a Singleton role as central fee ledger for modules to read from
    address immutable internal feeManager;

    /// @dev The balance recordkeeping for the specific child contract that inherits from this module
    /// @dev Accounts for the sum of both baseFee and variableFee, which are set in the FeeManager
    uint256 public totalFeeBalance;

    /*============
        ERRORS
    ============*/

    error InvalidFee(uint256 expected, uint256 received);

    /*============
        EVENTS
    ============*/

    event WithdrawFee(address indexed recipient, uint256 amount);

    /*=================
        ModuleFeeV2
    =================*/

    /// @param newOwner The initialization of the contract's owner address, managed by Station
    /// @param feeManagerProxy The UUPS proxy that serves as Station's central fee management ledger for all Memberships
    constructor(address newOwner, address feeManagerProxy) {
        _transferOwnership(newOwner);
        feeManager = feeManagerProxy;
    }

    /// @dev Function to withdraw the total balances of accrued base and variable fees that have been collected from mints
    /// @dev Sends fees to the module's owner address, which is managed by Station Network
    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = feeBalance;
        feeBalance = 0;
        payable(recipient).transfer(balance);
        emit WithdrawFee(recipient, balance);
    }

    /// @dev Function to update the feeBalance in storage when minting a single item
    function _registerFee() internal returns (uint256 paidFee) {
        return _registerFeeBatch(1);
    }

    /// @dev Function to update the feeBalance in storage when fees are paid to this module
    /// @param n The number of items being minted, used to calculate the total fee payment required
    function _registerFeeBatch(uint256 n) internal returns (uint256 paidFee) {
        // formerly: paidFee = fee * n; // read from state once, gas optimization
        // todo: FeeManager(feeManager).getFeeTotals();
        // accept funds only if the msg.value sent matches the FeeManager's calculation
        if (paidFee != msg.value) revert InvalidFee(paidFee, msg.value);
        // update balances
        feeBalance += paidFee;
    }
}
