// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccountInitializer} from "0xrails/lib/ERC6551AccountGroup/AccountInitializer.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";

import {AccountGroupLib} from "../lib/AccountGroupLib.sol";

/// @notice Verify sender has INITIALIZE_ACCOUNT permission
contract PermissionGatedInitializer is AccountInitializer {
    error InvalidPermission();

    /// @dev delegatecall'ed by 6551 Account
    function _authenticateInitialization(address, bytes memory initData)
        internal
        view
        override
        returns (bytes memory)
    {
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams();
        // Verify entity calling the 6551 Account (msg.sender) has INITIALIZE_ACCOUNT permission from Account Group
        if (!IPermissions(params.accountGroup).hasPermission(Operations.INITIALIZE_ACCOUNT, msg.sender)) {
            revert InvalidPermission();
        }
        return initData;
    }
}
