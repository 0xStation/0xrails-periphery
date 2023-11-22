// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "protocol-ops/script/lib/JsonManager.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/Permissions.sol";

import {AccountGroup} from "../../src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "../../src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "../../src/accountGroup/module/InitializeAccountController.sol";
import {ERC721AccountRails} from "0xrails/cores/ERC721Account/ERC721AccountRails.sol";
import {IOwnable} from "0xrails/access/ownable/interface/IOwnable.sol";

/// @dev Script to deploy entire AccountGroup infra to new chains
contract UpgradeAccountGroupProxyScript is ScriptUtils {
    /*=================
        ENVIRONMENT
    =================*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;
    address erc721AccountRails = $deploys.ERC721AccountRails;
    address accountGroupImpl = $deploys.AccountGroupImpl;
    address permissionGatedInitializer = $deploys.PermissionGatedInitializer;
    address initializeAccountController = $deploys.InitializeAccountController;
    address mintCreateInitializeController = $deploys.MintCreateInitializeController;

    // The following contracts will be upgraded:
    address accountGroup = $deploys.AccountGroupProxy; // production proxy

    bytes upgradeData; // configure if a function call is desired with the upgrade


    function run() public {
        /*===============
            BROADCAST
        ===============*/

        vm.startBroadcast();

        bytes32 salt = ScriptUtils.create2Salt;

        // begin deployments

        bytes memory upgradeCall =  abi.encodeWithSelector(
            UUPSUpgradeable.upgradeToAndCall.selector, address(accountGroupImpl), upgradeData
        );

        Call3 memory accountGroupUpgradeCall =
            Call3({target: accountGroup, allowFailure: false, callData: upgradeCall});
        
        bytes memory setDefaultAccountInitializer = abi.encodeWithSelector(
            AccountGroup.setDefaultAccountInitializer.selector, address(permissionGatedInitializer)
        );
        Call3 memory accountGroupSetDefaultAccountInitializerCall =
            Call3({target: address(accountGroup), allowFailure: false, callData: setDefaultAccountInitializer});

        bytes memory setDefaultAccountImplementation =
            abi.encodeWithSelector(AccountGroup.setDefaultAccountImplementation.selector, address(erc721AccountRails));
        Call3 memory accountGroupSetDefaultAccountImplementationCall =
            Call3({target: address(accountGroup), allowFailure: false, callData: setDefaultAccountImplementation});

        bytes memory addPermissionInitializeAccountToController = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)
        );
        Call3 memory addPermissionInitializeAccountToControllerCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountToController
        });

        bytes memory addPermissionInitializeAccountToMintController = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, address(mintCreateInitializeController)
        );
        Call3 memory addPermissionInitializeAccountToMintControllerCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountToMintController
        });

        bytes memory addPermissionInitializeAccountPermitToTurnkey = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey
        );
        Call3 memory addPermissionInitializeAccountPermitToTurnkeyCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountPermitToTurnkey
        });

        Call3[] memory calls = new Call3[](6);
        calls[0] = accountGroupUpgradeCall;
        calls[1] = accountGroupSetDefaultAccountInitializerCall;
        calls[2] = accountGroupSetDefaultAccountImplementationCall;
        calls[3] = addPermissionInitializeAccountToControllerCall;
        calls[4] = addPermissionInitializeAccountToMintControllerCall;
        calls[5] = addPermissionInitializeAccountPermitToTurnkeyCall;

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        assert(AccountGroup(accountGroup).getDefaultAccountInitializer() == permissionGatedInitializer);
        assert(AccountGroup(accountGroup).getDefaultAccountImplementation() == erc721AccountRails);
        assert(AccountGroup(accountGroup).hasPermission(Operations.INITIALIZE_ACCOUNT, initializeAccountController));
        assert(AccountGroup(accountGroup).hasPermission(Operations.INITIALIZE_ACCOUNT, mintCreateInitializeController));
        assert(AccountGroup(accountGroup).hasPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, turnkey));

        vm.stopBroadcast();

        logAddress("NewAccountGroupImpl @", Strings.toHexString(address(accountGroupImpl)));
    }
}