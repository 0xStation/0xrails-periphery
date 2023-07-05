// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions} from "src/lib/Permissions.sol";

contract ModuleSetup {
    error SetUpUnauthorized(address collection, address account);

    function _canSetUp(address collection, address account) internal view {
        if (!Permissions(collection).hasPermission(account, Permissions.Operation.UPGRADE)) {
            revert SetUpUnauthorized(collection, account);
        }
    }
}
