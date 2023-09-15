// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";

import {IPayoutAddress} from "./IPayoutAddress.sol";
import {PayoutAddressStorage} from "./PayoutAddressStorage.sol";

contract PayoutAddress is IPayoutAddress, Permissions {

    constructor() {
        // grant deployer the ADMIN permission
        _addPermission(Operations.ADMIN, msg.sender);
    }

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
        _checkCanUpdatePayoutAddress();
        if (newPayoutAddress == address(0)) revert PayoutAddressIsZero();
        _updatePayoutAddress(newPayoutAddress);
    }

    function removePayoutAddress() external virtual {
        _checkCanUpdatePayoutAddress();
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
        return hasPermission(Operations.ADMIN, msg.sender);
    }

    function _checkCanUpdatePermissions() internal virtual override {
        if (!hasPermission(Operations.ADMIN, msg.sender)) {
            revert PermissionDoesNotExist(Operations.ADMIN, msg.sender);
        }
    }
}
