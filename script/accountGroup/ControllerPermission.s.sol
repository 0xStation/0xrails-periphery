// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "protocol-ops/script/lib/JsonManager.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/Permissions.sol";
import {AccountGroup} from "../../src/accountGroup/implementation/AccountGroup.sol";

/// @dev Function to add INITIALIZE_PERMIT for a controller to the AccountGroup
contract ControllerPermissionScript is ScriptUtils {
    /*============
            CONFIG
        ============*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;
    address accountGroup = $deploys.AccountGroupProxy; // prod
    // prod: 0x12e58F259135b4B4ba87dff6086fB5D02C6A86ef // staging: 0x1131b9A9092E31b725567A8E93A7156A900a881b; // local: 0x169288565733188d1673606c423297ecA1855bfB

    address controller = 0x52E1d8A13284e50ef98CF6D0815B4f25F8Ff8e0B; // mint+create+initialize controller

    /*===============
            BROADCAST
        ===============*/

    function run() public {
        vm.startBroadcast();

        bytes memory addPermissionData =
            abi.encodeWithSelector(IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, controller);
        Call3 memory addPermissionCall = Call3({target: accountGroup, allowFailure: false, callData: addPermissionData});

        Call3[] memory calls = new Call3[](1);
        calls[0] = addPermissionCall;
        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);

        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );

        (bool r,) = owner.call(safeCall);
        require(r);

        assert(IPermissions(accountGroup).hasPermission(Operations.INITIALIZE_ACCOUNT, controller));

        vm.stopBroadcast();
    }
}
