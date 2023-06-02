// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions} from "src/lib/Permissions.sol";

contract ModuleSetup {
    function _canSetUp(address collection, address account) internal view {
        require(Permissions(collection).hasPermission(account, Permissions.Operation.UPGRADE), "NOT_PERMITTED");
    }
}
