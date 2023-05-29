// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions as PermissionsSrc} from "src/lib/Permissions.sol";

abstract contract Permissions {
    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(PermissionsSrc.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}
