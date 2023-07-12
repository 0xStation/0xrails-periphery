// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions} from "src/lib/Permissions.sol";

contract ModuleSetup {
    error SetUpUnauthorized(address collection, address account);

    // V1
    function _canSetUp(address collection, address account) internal view {
        if (!Permissions(collection).hasPermission(account, Permissions.Operation.UPGRADE)) {
            revert SetUpUnauthorized(collection, account);
        }
    }

    // V2: one modifier to be used on one setUp function
    modifier canSetUp(address collection) {
        if (
            collection != msg.sender
                && !Permissions(collection).hasPermission(msg.sender, Permissions.Operation.UPGRADE)
        ) {
            revert SetUpUnauthorized(collection, msg.sender);
        }
        _;
    }
}
