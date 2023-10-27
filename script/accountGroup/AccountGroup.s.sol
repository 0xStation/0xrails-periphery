// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/Permissions.sol";

import {AccountGroup} from "../../src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "../../src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "../../src/accountGroup/module/InitializeAccountController.sol";

contract AccountGroupScript is ScriptUtils {
    /*=================
        ENVIRONMENT 
    =================*/

    // The following contracts will be deployed:
    AccountGroup accountGroupImpl = AccountGroup(0x287224CFf44bDcfc234a7A85f76B42D719395D25); //todo;                               // -> 0x287224CFf44bDcfc234a7A85f76B42D719395D25
    AccountGroup accountGroupLocal; // proxy for local testing   // -> 
    AccountGroup accountGroupStaging; // proxy for stage testing // ->
    // AccountGroup accountGroup; // proxy for prod                 // -> 0x12e58F259135b4B4ba87dff6086fB5D02C6A86ef
    PermissionGatedInitializer permissionGatedInitializer;       // -> 0x97a44D858c6B79E456828bfD86c1A0aD86b1677b
    InitializeAccountController initializeAccountController;     // -> 0x6dBa22C55eA4549d1c92F181Cb33D7fe016E2f45

    /*============
        CONFIG 
    ============*/

    address owner = ScriptUtils.stationFounderSafe;

    string localSaltString = "local";
    bytes32 localSalt = bytes32(bytes(localSaltString));
    string stagingSaltString = "staging";
    bytes32 stagingSalt = bytes32(bytes(stagingSaltString));
    string saltString = "station";
    bytes32 salt = bytes32(bytes(saltString));

    Call3[] calls;

    function run() public {
        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        // begin deployments
        (/*accountGroupImpl,*/ accountGroupLocal, accountGroupStaging /*, accountGroup*/) = deployAccountGroup(localSalt, stagingSalt, salt, owner); //todo
        permissionGatedInitializer = PermissionGatedInitializer(0x97a44D858c6B79E456828bfD86c1A0aD86b1677b); // new PermissionGatedInitializer{salt: salt}(); //todo
        initializeAccountController = InitializeAccountController(0x6dBa22C55eA4549d1c92F181Cb33D7fe016E2f45); // new InitializeAccountController{salt: salt}(); //todo

        // After deployments, format Multicall3 calls and execute it from FounderSafe as module sender

        // LOCAL DEPLOY
        
        // accountGroup.setDefaultAccountInitializer(address(permissionGatedInitializer));
        // accountGroup.addPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController));
        // accountGroup.addPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey);

        // PRODUCTION DEPLOY 


        // delet
        // calls[0] = accountGroupSetDefaultAccountInitializerCall; //delet
        // calls[1] = addPermissionInitializeAccountToControllerCall; //delet
        // calls[2] = addPermissionInitializeAccountPermitToTurnkeyCall; //delet
        
        (bool r) = configureInitCalls(address(accountGroupLocal));
        require(r);
        (bool s) = configureInitCalls(address(accountGroupStaging));
        require(s);
        // (bool v) = configureInitCalls(address(accountGroup)); //todo
        // require(v);

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool ret,) = owner.call(safeCall);
        require(ret);

        // assert accountGroup calls successful
        // assert(accountGroup.getDefaultAccountInitializer() == address(permissionGatedInitializer));
        // assert(accountGroup.hasPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)));
        // assert(accountGroup.hasPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey));
        assert(accountGroupLocal.getDefaultAccountInitializer() == address(permissionGatedInitializer));
        assert(accountGroupLocal.hasPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)));
        assert(accountGroupLocal.hasPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey));
        assert(accountGroupStaging.getDefaultAccountInitializer() == address(permissionGatedInitializer));
        assert(accountGroupStaging.hasPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)));
        assert(accountGroupStaging.hasPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey));

        vm.stopBroadcast();

        // writeUsedSalt(saltString, string.concat("AccountGroupImpl @", Strings.toHexString(address(accountGroupImpl)))); //todo
        writeUsedSalt(localSaltString, string.concat("AccountGroupLocal @", Strings.toHexString(address(accountGroupLocal))));
        writeUsedSalt(stagingSaltString, string.concat("AccountGroupStaging @", Strings.toHexString(address(accountGroupStaging))));
        // writeUsedSalt(saltString, string.concat("AccountGroupProxy @", Strings.toHexString(address(accountGroup)))); //todo

        // todo
        // writeUsedSalt(
        //     saltString,
        //     string.concat("PermissionGatedInitializer @", Strings.toHexString(address(permissionGatedInitializer)))
        // );
        // writeUsedSalt(
        //     saltString,
        //     string.concat("InitializeAccountController @", Strings.toHexString(address(initializeAccountController)))
        // );
    }

    function deployAccountGroup(bytes32 _localSalt, bytes32 _stagingSalt, bytes32 _salt, address _owner)
        internal
        returns (/*AccountGroup _impl,*/ AccountGroup _localProxy, AccountGroup _stagingProxy/*, AccountGroup _prodProxy*/) //todo
    {
        // _impl = new AccountGroup{salt: _salt}(); //todo
        AccountGroup _impl = accountGroupImpl;

        bytes memory accountGroupInitData = abi.encodeWithSelector(AccountGroup.initialize.selector, _owner);
        _localProxy = AccountGroup(address(new ERC1967Proxy{salt: _localSalt}(address(_impl), accountGroupInitData)));
        _stagingProxy = AccountGroup(address(new ERC1967Proxy{salt: _stagingSalt}(address(_impl), accountGroupInitData)));
        // _proxy = AccountGroup(address(new ERC1967Proxy{salt: _salt}(address(_impl), accountGroupInitData))); //todo
    }

    /// @dev Function required to prevent "stack too deep" errors
    function configureInitCalls(address _accountGroupProxy) internal returns (bool) {
        bytes memory setDefaultAccountInitializer = abi.encodeWithSelector(
            AccountGroup.setDefaultAccountInitializer.selector, address(permissionGatedInitializer)
        );
        bytes memory addPermissionInitializeAccountToController = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)
        );
        bytes memory addPermissionInitializeAccountPermitToTurnkey = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey
        );

        Call3 memory accountGroupSetDefaultAccountInitializerCall =
            Call3({target: _accountGroupProxy, allowFailure: false, callData: setDefaultAccountInitializer});
        Call3 memory addPermissionInitializeAccountToControllerCall = 
            Call3({target: _accountGroupProxy, allowFailure: false, callData: addPermissionInitializeAccountToController});
        Call3 memory addPermissionInitializeAccountPermitToTurnkeyCall = 
            Call3({target: _accountGroupProxy, allowFailure: false, callData: addPermissionInitializeAccountPermitToTurnkey});
        
        calls.push(accountGroupSetDefaultAccountInitializerCall);
        calls.push(addPermissionInitializeAccountToControllerCall);
        calls.push(addPermissionInitializeAccountPermitToTurnkeyCall);
    }
}
