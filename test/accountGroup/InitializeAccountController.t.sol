// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC6551Registry} from "erc6551/ERC6551Registry.sol";
import {ERC6551BytecodeLib} from "erc6551/lib/ERC6551BytecodeLib.sol";
import {ERC6551AccountLib} from "erc6551/lib/ERC6551AccountLib.sol";
import {ERC721Holder} from "openzeppelin-contracts/token/ERC721/utils/ERC721Holder.sol";
import {Account} from "test/lib/helpers/Account.sol";
import {AccountGroupStorage} from "src/accountGroup/implementation/AccountGroupStorage.sol";
import {AccountGroup} from "src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "../../src/accountGroup/module/InitializeAccountController.sol";
import {IAccountGroup} from "src/accountGroup/interface/IAccountGroup.sol";
import {AccountGroupLib} from "src/accountGroup/lib/AccountGroupLib.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {PermitController} from "src/lib/module/PermitController.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {IOwnableInternal} from "0xrails/access/ownable/interface/IOwnable.sol";
import {IPermissionsInternal} from "0xrails/access/permissions/interface/IPermissions.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {BotAccount} from "0xrails/cores/account/BotAccount.sol";

contract InitializeAccountControllerTest is Test, Account {

    ERC6551Registry erc6551Registry;
    TokenFactory tokenFactoryImpl;
    TokenFactory tokenFactoryProxy;
    ERC721Rails erc721RailsImpl;
    ERC721Rails erc721Rails;
    ERC721Holder user;
    BotAccount botAccountImpl;
    BotAccount botAccount;
    AccountGroup accountGroupImpl;
    AccountGroup accountGroup; // proxy
    PermissionGatedInitializer permissionGatedInitializer;
    InitializeAccountController initializeAccountController;

    address owner;
    address entryPointAddress;
    bytes32 bytecodeSalt;
    bytes initData;

    function setUp() public {
        owner = createAccount();
        entryPointAddress = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

        erc6551Registry = new ERC6551Registry();
        
        tokenFactoryImpl = new TokenFactory();
        tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
        tokenFactoryProxy.initialize(owner);

        erc721RailsImpl = new ERC721Rails();
        erc721Rails = ERC721Rails(tokenFactoryProxy.createERC721(payable(address(erc721RailsImpl)), owner, "test", "tst", ''));
        user = new ERC721Holder();
        vm.prank(owner);
        erc721Rails.mintTo(address(user), 1);

        botAccountImpl = new BotAccount(entryPointAddress);
        botAccount = BotAccount(payable(address(new ERC1967Proxy(address(botAccountImpl), ''))));
        // throwaway initialization just for testing purposes
        botAccount.initialize(owner, address(0x0), new address[](0));

        accountGroupImpl = new AccountGroup();
        initData = abi.encodeWithSelector(AccountGroup.initialize.selector, owner);
        accountGroup = AccountGroup(address(new ERC1967Proxy(address(accountGroupImpl), initData)));

        bytecodeSalt = bytes32(abi.encodePacked(address(accountGroup), type(uint64).max, uint32(0)));

        permissionGatedInitializer = new PermissionGatedInitializer();
        initializeAccountController = new InitializeAccountController();
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

    function test_createAndInitializeAccountOwner() public {        
        uint256 tokenId = 1;
        bytes memory data;

        vm.prank(owner);
        address tba = initializeAccountController.createAndInitializeAccount(address(erc6551Registry), address(accountGroup), bytecodeSalt, block.chainid, address(erc721Rails), tokenId, address(botAccountImpl), data);

        // assert contract was created with expected bytecode
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(tba));
        bytes32 packedParams = bytes32(abi.encodePacked(params.accountGroup, params.subgroupId, params.index));
        assertEq(packedParams, bytecodeSalt);
    }

    function test_createAndInitializeAccountPermission() public {        
        uint256 tokenId = 1;
        bytes memory data;

        // grant user permission to create accounts
        vm.prank(owner);
        IPermissions(address(accountGroup)).addPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, address(user));

        vm.prank(address(user));
        address tba = initializeAccountController.createAndInitializeAccount(address(erc6551Registry), address(accountGroup), bytecodeSalt, block.chainid, address(erc721Rails), tokenId, address(botAccountImpl), data);

        // assert contract was created with expected bytecode
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(tba));
        bytes32 packedParams = bytes32(abi.encodePacked(params.accountGroup, params.subgroupId, params.index));
        assertEq(packedParams, bytecodeSalt);
    }

    function test_createAndInitializeAccountRevertPermitSignerInvalid() public {        
        uint256 tokenId = 1;
        bytes memory data;

        vm.expectRevert(abi.encodeWithSelector(PermitController.PermitSignerInvalid.selector, address(0x1)));
        initializeAccountController.createAndInitializeAccount(address(erc6551Registry), address(accountGroup), bytecodeSalt, block.chainid, address(erc721Rails), tokenId, address(botAccountImpl), data);
    }
}
