// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/Permissions.sol";
import {ERC2771Forwarder} from "0xrails/lib/ERC2771/ERC2771Forwarder.sol";

import {AccountGroup} from "../../src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "../../src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "../../src/accountGroup/module/InitializeAccountController.sol";
import {MintCreateInitializeController} from "src/accountGroup/module/MintCreateInitializeController.sol";
import {ERC721AccountRails} from "0xrails/cores/ERC721Account/ERC721AccountRails.sol";

/// @dev Script to deploy entire AccountGroup infra to new chains
contract AccountGroupScript is ScriptUtils {
    /*=================
        ENVIRONMENT
    =================*/

    // The following contracts will be deployed:
    AccountGroup accountGroupImpl;
    AccountGroup accountGroup; // proxy
    ERC2771Forwarder forwarder;
    PermissionGatedInitializer permissionGatedInitializer;
    InitializeAccountController initializeAccountController;
    MintCreateInitializeController mintCreateInitializeController;
    ERC721AccountRails erc721AccountRails;

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;

    bytes32 salt = ScriptUtils.create2Salt;

    string domainName = "GroupOSForwarder";

    function run() public {
        /*===============
            BROADCAST
        ===============*/

        vm.startBroadcast();

        // begin deployments
        (accountGroupImpl, accountGroup) = deployAccountGroup(salt, owner);
        forwarder = new ERC2771Forwarder{salt: salt}(domainName);
        permissionGatedInitializer = new PermissionGatedInitializer{salt: salt}();
        initializeAccountController = new InitializeAccountController{salt: salt}(address(forwarder));
        mintCreateInitializeController = new MintCreateInitializeController{salt: salt}(address(forwarder));
        erc721AccountRails = new ERC721AccountRails{salt: salt}(ScriptUtils.entryPointAddress);

        // LOCAL CONFIG

        // accountGroup.setDefaultAccountInitializer(address(permissionGatedInitializer));
        // accountGroup.setDefaultAccountImplementation(address(erc721AccountRails));
        // accountGroup.addPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController));
        // accountGroup.addPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey);

        // PRODUCTION CONFIG

        // After deployments, format Multicall3 calls and execute it from FounderSafe as module sender
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

        bytes memory addPermissionInitializeAccountPermitToTurnkey = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey
        );
        Call3 memory addPermissionInitializeAccountPermitToTurnkeyCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountPermitToTurnkey
        });

        // `AccountGroup::addPermission(INITIALIZE_ACCOUNT, mintCreateInitializeController)` configuration
        bytes memory addPermissionInitializeAccountToMintCreateInitializeController = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, address(mintCreateInitializeController)
        );
        Call3 memory addPermissionInitializeAccountToMintCreateInitializeControllerCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountToMintCreateInitializeController
        });

        Call3[] memory calls = new Call3[](5);
        calls[0] = accountGroupSetDefaultAccountInitializerCall;
        calls[1] = accountGroupSetDefaultAccountImplementationCall;
        calls[2] = addPermissionInitializeAccountToControllerCall;
        calls[3] = addPermissionInitializeAccountPermitToTurnkeyCall;
        calls[4] = addPermissionInitializeAccountToMintCreateInitializeControllerCall;

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        // assert accountGroup call successful
        assert(accountGroup.getDefaultAccountInitializer() == address(permissionGatedInitializer));
        assert(accountGroup.getDefaultAccountImplementation() == address(erc721AccountRails));
        assert(accountGroup.hasPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)));
        assert(accountGroup.hasPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey));
        assert(erc721AccountRails.initialized() == true);

        vm.stopBroadcast();

        logAddress("AccountGroupImpl @", Strings.toHexString(address(accountGroupImpl)));
        logAddress("AccountGroupProxy @", Strings.toHexString(address(accountGroup)));
        logAddress("ERC2771Forwarder @", Strings.toHexString(address(forwarder)));
        logAddress("PermissionGatedInitializer @", Strings.toHexString(address(permissionGatedInitializer)));
        logAddress("InitializeAccountController @", Strings.toHexString(address(initializeAccountController)));
        logAddress("MintCreateInitializeController @", Strings.toHexString(address(mintCreateInitializeController)));
        logAddress("ERC721AccountRails @", Strings.toHexString(address(erc721AccountRails)));
    }

    function deployAccountGroup(bytes32 _salt, address _owner)
        internal
        returns (AccountGroup _impl, AccountGroup _proxy)
    {
        _impl = new AccountGroup{salt: _salt}();
        bytes memory accountGroupInitData = abi.encodeWithSelector(AccountGroup.initialize.selector, _owner);
        _proxy = AccountGroup(address(new ERC1967Proxy{salt: _salt}(address(_impl), accountGroupInitData)));
    }
}
