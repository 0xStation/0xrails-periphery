// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Access} from "mage/access/Access.sol";

import {IPayoutAddressExtensionExternal} from "./IPayoutAddressExtension.sol";
import {PayoutAddressExtensionInternal} from "./PayoutAddressExtensionInternal.sol";
import {PayoutAddressExtensionStorage} from "./PayoutAddressExtensionStorage.sol";

abstract contract PayoutAddressExtension is Access, PayoutAddressExtensionInternal, IPayoutAddressExtensionExternal {
    /*===========
        VIEWS
    ===========*/

    /*=============
        SETTERS
    =============*/
    function updatePayoutAddress(address payoutAddress) external virtual {
        checkCanUpdatePayoutAddress();
        _setPayoutAddress(payoutAddress);
    }

    /*====================
        AUTHORITZATION
    ====================*/

    // make public with return to be callable by UIs to enable/disable input
    function checkCanUpdatePayoutAddress() public virtual returns (bool) {
        /// @dev TODO: what happens with virtual owner() from Access??
        /// @dev maybe need Access to make an external self-call to use whatever owner() implementation
        _checkSenderIsAdmin();
        return true;
    }
}
