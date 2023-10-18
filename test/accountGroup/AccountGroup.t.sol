// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Account} from "test/lib/helpers/Account.sol";
import {AccountGroupStorage} from "src/accountGroup/implementation/AccountGroupStorage.sol";
import {AccountGroup} from "src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {IAccountGroup} from "src/accountGroup/interface/IAccountGroup.sol";
import {AccountGroupLib} from "src/accountGroup/lib/AccountGroupLib.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IOwnableInternal} from "0xrails/access/ownable/interface/IOwnable.sol";
import {IPermissionsInternal} from "0xrails/access/permissions/interface/IPermissions.sol";


contract AccountGroupTest is Test, Account {

    AccountGroup accountGroupImpl;
    AccountGroup accountGroup; // proxy
    PermissionGatedInitializer permissionGatedInitializer;

    address owner;
    bytes32 salt;
    bytes initData;

    function setUp() public {
        owner = createAccount();
        salt = bytes32(hex'ff');

        accountGroupImpl = new AccountGroup{salt: salt}();
        initData = abi.encodeWithSelector(AccountGroup.initialize.selector, owner);
        accountGroup = AccountGroup(address(new ERC1967Proxy{salt: salt}(address(accountGroupImpl), initData)));

        permissionGatedInitializer = new PermissionGatedInitializer{salt: salt}();
    }

    function test_setUp() public {
        assertTrue(accountGroup.initialized());
        assertTrue(accountGroupImpl.initialized());
        assertEq(accountGroup.owner(), owner);
        assertEq(accountGroupImpl.owner(), address(0x0));
        assertTrue(accountGroup.hasPermission(Operations.ADMIN, owner));
        // assert AccountInitializer has not yet been set
        assertEq(accountGroup.getDefaultAccountInitializer(), address(0x0));
        assertEq(accountGroup.getAccountInitializer(address(accountGroup)), address(0x0));
    }

    function test_setDefaultAccountInitializer() public {
        assertEq(accountGroup.getDefaultAccountInitializer(), address(0x0));
        
        // set initializer
        vm.prank(owner);
        accountGroup.setDefaultAccountInitializer(address(permissionGatedInitializer));
        address newInitializer = accountGroup.getDefaultAccountInitializer();
        assertEq(newInitializer, address(permissionGatedInitializer));
    }

    function test_setDefaultAccountInitializerRevertOnlyOwner() public {
        assertEq(accountGroup.getDefaultAccountInitializer(), address(0x0));

        // attempt to set initializer as not owner
        vm.expectRevert(abi.encodeWithSelector(IOwnableInternal.OwnerUnauthorizedAccount.selector, address(this)));
        accountGroup.setDefaultAccountInitializer(address(permissionGatedInitializer));

        // assert no state changes
        assertEq(accountGroup.getDefaultAccountInitializer(), address(0x0));
    }

    function test_setAccountInitializer() public {
        assertEq(accountGroup.getAccountInitializer(address(accountGroup)), address(0x0));

        // fetch subgroupId
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(accountGroup));
        
        // set initializer
        vm.prank(owner);
        accountGroup.setAccountInitializer(params.subgroupId, address(permissionGatedInitializer));
        address newInitializer = accountGroup.getAccountInitializer(address(accountGroup));
        assertEq(newInitializer, address(permissionGatedInitializer));
    }

    function test_setAccountInitializerRevert() public {
        assertEq(accountGroup.getAccountInitializer(address(accountGroup)), address(0x0));

        // fetch subgroupId
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(accountGroup));
        
        // attempt to set initializer without permission
        vm.expectRevert(abi.encodeWithSelector(IPermissionsInternal.PermissionDoesNotExist.selector, Operations.ADMIN, address(this)));
        accountGroup.setAccountInitializer(params.subgroupId, address(permissionGatedInitializer));
        // assert no state changes made
        assertEq(accountGroup.getAccountInitializer(address(accountGroup)), address(0x0));
    }
}
