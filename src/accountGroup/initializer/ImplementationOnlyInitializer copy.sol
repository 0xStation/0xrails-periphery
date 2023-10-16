// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccountInitializer} from "./AccountInitializer.sol";
import {ERC6551AccountGroupLib} from "../lib/ERC6551AccountGroupLib.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";

// Only initialize accounts with an implementation
contract ImplementationOnlyInitializer is AccountInitializer {
    error InvalidImplementation();

    /// @notice Check is account implementation is allowed, strip provided initData
    function _authenticateInitialization(address accountImpl, bytes memory initData) internal view returns (bytes) {
        // verify accountImpl, revert if invalid
        (address accountGroup,,) = ERC6551AccountGroupLib.accountParams();
        if (!IPermissions(accountGroup).hasPermission(Operations.ACCOUNT_INITIALIZER, accountImpl)) {
            revert InvalidImplementation();
        }

        return bytes("");
    }
}
