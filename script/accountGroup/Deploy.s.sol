// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {AccountGroup} from "../../src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "../../src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "../../src/accountGroup/module/InitializeAccountController.sol";

contract Deploy is ScriptUtils {
    /*=================
        ENVIRONMENT 
    =================*/

    // The following contracts will be deployed:
    AccountGroup accountGroupImpl;
    AccountGroup accountGroup; // proxy
    PermissionGatedInitializer permissionGatedInitializer;
    InitializeAccountController initializeAccountController;

    function run() public {
        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        address owner = ScriptUtils.stationFounderSafe;

        string memory saltString = ScriptUtils.readSalt("salt");
        bytes32 salt = bytes32(bytes(saltString));

        // begin deployments
        (accountGroupImpl, accountGroup) = deployAccountGroup(salt, owner);
        permissionGatedInitializer = new PermissionGatedInitializer{salt: salt}();
        initializeAccountController = new InitializeAccountController{salt: salt}();

        // After deployments, format Multicall3 calls and execute it from FounderSafe as module sender
        // `MetadataRouter::setDefaultURI()` configuration
        bytes memory setDefaultAccountInitializer = abi.encodeWithSelector(
            AccountGroup.setDefaultAccountInitializer.selector, address(permissionGatedInitializer)
        );
        Call3 memory accountGroupSetDefaultAccountInitializerCall =
            Call3({target: address(accountGroup), allowFailure: false, callData: setDefaultAccountInitializer});

        Call3[] memory calls = new Call3[](1);
        calls[0] = accountGroupSetDefaultAccountInitializerCall;
        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        // assert accountGroup call successful
        assert(accountGroup.getDefaultAccountInitializer() == address(permissionGatedInitializer));

        vm.stopBroadcast();

        writeUsedSalt(saltString, string.concat("AccountGroupImpl @", Strings.toHexString(address(accountGroupImpl))));
        writeUsedSalt(saltString, string.concat("AccountGroupProxy @", Strings.toHexString(address(accountGroup))));
        writeUsedSalt(
            saltString,
            string.concat("PermissionGatedInitializer @", Strings.toHexString(address(permissionGatedInitializer)))
        );
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
