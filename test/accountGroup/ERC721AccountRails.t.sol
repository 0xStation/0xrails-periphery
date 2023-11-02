// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {IAccount} from "0xrails/lib/ERC4337/interface/IAccount.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions, IPermissionsInternal} from "0xrails/access/permissions/interface/IPermissions.sol";
import {ERC721Harness} from "lib/0xrails/test/cores/ERC721/helpers/ERC721Harness.sol";
import {ERC721ReceiverImplementer} from "lib/0xrails/test/cores/ERC721/helpers/ERC721ReceiverImplementer.sol";
import {MockAccountDeployer} from "lib/0xrails/test/lib/MockAccount.sol";
import {ERC6551Account, IERC6551Account} from "0xrails/lib/ERC6551/ERC6551Account.sol";
import {ERC6551AccountLib} from "erc6551/lib/ERC6551AccountLib.sol";
import {ERC6551Registry} from "erc6551/ERC6551Registry.sol";
import {AccountGroup} from "src/accountGroup/implementation/AccountGroup.sol";
import {AccountGroupLib} from "src/accountGroup/lib/AccountGroupLib.sol";
import {PermissionGatedInitializer} from "src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "src/accountGroup/module/InitializeAccountController.sol";
import {ERC721AccountRails} from "0xrails/cores/ERC721Account/ERC721AccountRails.sol";
import {AccountProxy} from "0xrails/lib/ERC6551AccountGroup/AccountProxy.sol";

contract ERC721AccountRailsTest is Test, MockAccountDeployer {

    ERC721Harness erc721;
    ERC6551Registry erc6551Registry;
    AccountProxy accountProxy;
    AccountGroup accountGroupImpl;
    AccountGroup accountGroupProxy;
    PermissionGatedInitializer permissionGatedInitializer;
    InitializeAccountController initializeAccountController;
    ERC721AccountRails erc721AccountRailsImpl;
    ERC721AccountRails erc721AccountRailsProxy; // wrapped 1967 proxy
    ERC721AccountRails erc6551UserAccount; // wrapped 1167 proxy
    

    address public entryPointAddress;
    address public accountGroupOwner; // ie an accountgroup's multisig
    address public tokenOwner; // ie a user
    uint256 public tokenId;
    bytes32 public bytecodeSalt;
    bytes public initData;

    // to store expected revert errors
    bytes err;

    function setUp() public {
        entryPointAddress = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

        // create vanilla ERC721 and mint token to be bound to erc721AccountRails
        tokenOwner = createAccount();
        erc721 = new ERC721Harness();
        erc721.mint(tokenOwner, 2); // mints [0, 1]
        tokenId = 1;

        // create accountgroup infra
        accountGroupOwner = createAccount();
        accountGroupImpl = new AccountGroup();
        initData = abi.encodeWithSelector(AccountGroup.initialize.selector, accountGroupOwner);
        accountGroupProxy = AccountGroup(address(new ERC1967Proxy(address(accountGroupImpl), initData)));

        // deploy initializer infra to guard against unauthorized erc6551 account creation
        permissionGatedInitializer = new PermissionGatedInitializer();
        // set PermissionGatedInitializer to defaultInitializer (as owner)
        vm.startPrank(accountGroupOwner);
        accountGroupProxy.setDefaultAccountInitializer(address(permissionGatedInitializer));
        
        // deploy and grant INITIALIZE_ACCOUNT permission to the InitializeAccountController
        initializeAccountController = new InitializeAccountController();
        accountGroupProxy.addPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController));
        vm.stopPrank();

        // create ERC6551 registry + AccountProxy singleton, deploy erc721accountrails 'implementation' (which is upgradeable via proxy)
        erc6551Registry = new ERC6551Registry();
        accountProxy = new AccountProxy();
        erc721AccountRailsImpl = new ERC721AccountRails(entryPointAddress);
        erc721AccountRailsProxy = ERC721AccountRails(payable(address(new ERC1967Proxy(address(erc721AccountRailsImpl), ''))));
        // it is very important to initialize the ERC721AccountRailsProxy since it is being used as a quasi "implementation"
        erc721AccountRailsProxy.initialize('');

        // `subGroupId 0xffffffffffffffff`, `index: 0`
        bytecodeSalt = bytes32(abi.encodePacked(address(accountGroupProxy), type(uint64).max, uint32(0)));

        // create ERC6551 account through the InitializeAccountController
        vm.prank(accountGroupOwner);
        bytes memory erc6551UserAccountInitData = abi.encodeWithSelector(ERC721AccountRails.initialize.selector, '');
        erc6551UserAccount = ERC721AccountRails(payable(initializeAccountController.createAndInitializeAccount(
            address(erc6551Registry), 
            address(accountProxy), 
            bytecodeSalt, 
            block.chainid, 
            address(erc721), 
            tokenId, 
            address(erc721AccountRailsImpl),
            erc6551UserAccountInitData
        )));
    }

    function test_setUp() public {
        assertTrue(accountGroupProxy.initialized());
        assertTrue(accountGroupImpl.initialized());
        assertEq(accountGroupProxy.owner(), accountGroupOwner);
        assertTrue(accountGroupProxy.hasPermission(Operations.ADMIN, accountGroupOwner)); // owners pass ADMIN by default
        assertEq(accountGroupImpl.owner(), address(0x0));

        // assert bytecode salt was set as expected
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(erc6551UserAccount));
        bytes32 packedParams = bytes32(abi.encodePacked(params.accountGroup, params.subgroupId, params.index));
        assertEq(packedParams, bytecodeSalt);
        
        assertTrue(erc721AccountRailsImpl.initialized());
        assertTrue(erc721AccountRailsProxy.initialized()); // initialized manually
        assertTrue(erc6551UserAccount.initialized()); // initialized by InitializeAccountController

        assertEq(erc6551UserAccount.owner(), tokenOwner);
    }

    function test_supportsInterface() public {
        // check support for ERC6551Account interface
        assertTrue(erc721AccountRailsProxy.supportsInterface(type(IERC6551Account).interfaceId));
        assertTrue(erc6551UserAccount.supportsInterface(type(IERC6551Account).interfaceId));
        
        // check support for ERC4337Account interface via inheritance of AccountRails
        assertTrue(erc721AccountRailsProxy.supportsInterface(type(IAccount).interfaceId));
        assertTrue(erc6551UserAccount.supportsInterface(type(IAccount).interfaceId));
    }

    function test_upgradeToAndCall() public {
        ERC721AccountRails newImpl = new ERC721AccountRails(entryPointAddress);

        bytes32 IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address oldImpl = address(uint160(uint256(vm.load(address(erc6551UserAccount), IMPLEMENTATION_SLOT))));
        assertEq(oldImpl, address(erc721AccountRailsImpl));
        
        // grab relevant subgroupId
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(erc6551UserAccount));

        // AccountGroups have say over how the erc721accountrails gets upgraded via ADMIN permission
        vm.prank(accountGroupOwner);
        accountGroupProxy.addApprovedImplementation(params.subgroupId, address(newImpl));
        UUPSUpgradeable(address(erc6551UserAccount)).upgradeToAndCall(address(newImpl), '');

        address updatedImpl = address(uint160(uint256(vm.load(address(erc6551UserAccount), IMPLEMENTATION_SLOT))));
        assertEq(updatedImpl, address(newImpl));
        assertTrue(updatedImpl != oldImpl);
    }

    function test_removeApprovedImplementation() public {
        ERC721AccountRails newImpl = new ERC721AccountRails(entryPointAddress);

        // grab relevant subgroupId
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(erc6551UserAccount));

        vm.prank(accountGroupOwner);
        accountGroupProxy.addApprovedImplementation(params.subgroupId, address(newImpl));

        address[] memory addedImplArray = accountGroupProxy.getApprovedImplementations(address(erc6551UserAccount));
        assertEq(addedImplArray.length, 1);
        assertEq(addedImplArray[0], address(newImpl));

        vm.prank(accountGroupOwner);
        accountGroupProxy.removeApprovedImplementation(params.subgroupId, address(newImpl));
        address[] memory removedImplArray = accountGroupProxy.getApprovedImplementations(address(erc6551UserAccount));
        assertEq(removedImplArray.length, 1); // deleted members remain but are set to 0
        assertEq(removedImplArray[0], address(0x0));
    }

    function test_permissionBehaviorOnTransfer() public {
        assertEq(erc6551UserAccount.owner(), tokenOwner);
        
        // add high severity ADMIN permission to tokenOwner in AccountGroup contract
        // note that the token itself also has a permissioning system via AccountRails
        vm.prank(accountGroupOwner);
        accountGroupProxy.addPermission(Operations.ADMIN, tokenOwner);

        address newTokenOwner = createAccount();
        vm.prank(tokenOwner);
        erc721.transfer(tokenOwner, newTokenOwner, 1);

        assertEq(erc6551UserAccount.owner(), newTokenOwner);
        // new token owner should not inherit permissions of previous owner
        assertFalse(accountGroupProxy.hasPermission(Operations.ADMIN, newTokenOwner));
        // previous owner permission remains
        assertTrue(accountGroupProxy.hasPermission(Operations.ADMIN, tokenOwner));

        // permissions can also be granted to the TBA itself, which does transmit through transfers
        vm.prank(accountGroupOwner);
        accountGroupProxy.addPermission(Operations.ADMIN, address(erc6551UserAccount));

        assertTrue(accountGroupProxy.hasPermission(Operations.ADMIN, address(erc6551UserAccount)));

        erc721.transfer(newTokenOwner, tokenOwner, 1);

        // assert transfer back to original owner succeeded
        assertEq(erc6551UserAccount.owner(), tokenOwner);
        // assert TBA's permissions unchanged
        assertTrue(accountGroupProxy.hasPermission(Operations.ADMIN, address(erc6551UserAccount)));
        // assert owner address permissions unchanged
        assertTrue(accountGroupProxy.hasPermission(Operations.ADMIN, tokenOwner));
        assertFalse(accountGroupProxy.hasPermission(Operations.ADMIN, newTokenOwner));
    }

    // function test_nonOriginOwner() public {}
    // function test_state
}