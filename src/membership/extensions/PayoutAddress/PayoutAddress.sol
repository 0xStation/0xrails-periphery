// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails//access/permissions/interface/IPermissions.sol";
import {IPayoutAddress} from "./IPayoutAddress.sol";
import {PayoutAddressStorage} from "./PayoutAddressStorage.sol";

contract PayoutAddress is IPayoutAddress {

    /*===========
        VIEWS
    ===========*/

    function payoutAddress() public view virtual returns (address) {
        PayoutAddressStorage.Layout storage layout = PayoutAddressStorage.layout();
        return layout.payoutAddress;
    }

    /*=============
        SETTERS
    =============*/

    function updatePayoutAddress(address newPayoutAddress) external virtual {
        if (!_checkCanUpdatePayoutAddress()) revert PermissionDoesNotExist(Operations.ADMIN, msg.sender);
        if (newPayoutAddress == address(0)) revert PayoutAddressIsZero();
        _updatePayoutAddress(newPayoutAddress);
    }

    function removePayoutAddress() external virtual {
        if (!_checkCanUpdatePayoutAddress()) revert PermissionDoesNotExist(Operations.ADMIN, msg.sender);
        _updatePayoutAddress(address(0));
    }

    function _updatePayoutAddress(address newPayoutAddress) internal {
        PayoutAddressStorage.Layout storage layout = PayoutAddressStorage.layout();
        emit PayoutAddressUpdated(layout.payoutAddress, newPayoutAddress);
        layout.payoutAddress = newPayoutAddress;
    }

    /*====================
        AUTHORIZATION
    ====================*/

    function _checkCanUpdatePayoutAddress() internal virtual returns (bool) {
        return IPermissions(address(this)).hasPermission(Operations.ADMIN, msg.sender);
    }
}
