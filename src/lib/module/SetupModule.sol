// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";

abstract contract SetupModule {
    error SetUpUnauthorized(address collection, address account);

    modifier canSetUp(address collection) {
        if (collection != msg.sender && !IPermissions(collection).hasPermission(Operations.ADMIN, msg.sender)) {
            revert SetUpUnauthorized(collection, msg.sender);
        }
        _;
    }
}
