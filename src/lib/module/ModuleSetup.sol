// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPermissions} from "mage/access/permissions/interface/IPermissions.sol";
import {Operations} from "mage/lib/Operations.sol";

contract ModuleSetup {
    error SetUpUnauthorized(address collection, address account);

    modifier canSetUp(address collection) {
        if (collection != msg.sender && !IPermissions(collection).hasPermission(Operations.ADMIN, msg.sender)) {
            revert SetUpUnauthorized(collection, msg.sender);
        }
        _;
    }
}
