// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC6551Registry} from "0xrails/lib/ERC6551/ERC6551Registry.sol";
import {ERC6551BytecodeLib} from "0xrails/lib/ERC6551/ERC6551Registry.sol";
import {ERC6551AccountLib} from "0xrails/lib/ERC6551/lib/ERC6551AccountLib.sol";
import {ERC721Holder} from "openzeppelin-contracts/token/ERC721/utils/ERC721Holder.sol";
import {Account} from "test/lib/helpers/Account.sol";
import {AccountGroupStorage} from "src/accountGroup/implementation/AccountGroupStorage.sol";
import {AccountGroup} from "src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {MintCreateInitializeController} from "src/accountGroup/module/MintCreateInitializeController.sol";
import {IAccountGroup} from "src/accountGroup/interface/IAccountGroup.sol";
import {AccountGroupLib} from "src/accountGroup/lib/AccountGroupLib.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {PermitController} from "src/lib/module/PermitController.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {IOwnable} from "0xrails/access/ownable/interface/IOwnable.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {ERC721AccountRails} from "0xrails/cores/ERC721Account/ERC721AccountRails.sol";
import {AccountProxy} from "0xrails/lib/ERC6551AccountGroup/AccountProxy.sol";

contract MintCreateInitializeControllerTest is Test, Account {
    ERC6551Registry erc6551Registry;
    AccountProxy accountProxy;
    TokenFactory tokenFactoryImpl;
    TokenFactory tokenFactoryProxy;
    ERC721Rails erc721RailsImpl;
    ERC721Rails erc721Rails;
    ERC721Holder user;
    AccountGroup accountGroupImpl;
    AccountGroup accountGroup; // proxy
    PermissionGatedInitializer permissionGatedInitializer;
    MintCreateInitializeController mintCreateInitializeController;
    ERC721AccountRails erc721AccountRails;

    bytes32 inputSalt;
    address owner;
    address entryPointAddress;
    address turnkey;
    bytes32 bytecodeSalt;
    bytes initData;

    MintCreateInitializeController.MintParams mintParams;

    function setUp() public {
        inputSalt = bytes32(0x0);
        owner = createAccount();
        turnkey = createAccount();
        entryPointAddress = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

        erc6551Registry = new ERC6551Registry();
        accountProxy = new AccountProxy();

        tokenFactoryImpl = new TokenFactory();
        tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));

        erc721RailsImpl = new ERC721Rails();
        // erc20 and erc1155 implementations + forwarder not needed for testing
        tokenFactoryProxy.initialize(owner, address(0x0), address(erc721RailsImpl), address(0x0), address(0x0));

        erc721Rails = ERC721Rails(
            tokenFactoryProxy.createERC721(payable(address(erc721RailsImpl)), inputSalt, owner, "test", "tst", "")
        );

        user = new ERC721Holder();

        erc721AccountRails = new ERC721AccountRails(entryPointAddress);

        accountGroupImpl = new AccountGroup();
        initData = abi.encodeWithSelector(AccountGroup.initialize.selector, owner);
        accountGroup = AccountGroup(address(new ERC1967Proxy(address(accountGroupImpl), initData)));

        bytecodeSalt = bytes32(abi.encodePacked(address(accountGroup), type(uint64).max, uint32(0)));

        permissionGatedInitializer = new PermissionGatedInitializer();
        vm.startPrank(owner);
        accountGroup.setDefaultAccountImplementation(address(erc721AccountRails));
        accountGroup.setDefaultAccountInitializer(address(permissionGatedInitializer));

        mintCreateInitializeController = new MintCreateInitializeController();

        // add permission for minting on erc71RailsProxy and accountGroup to controller
        vm.startPrank(owner);
        accountGroup.addPermission(Operations.INITIALIZE_ACCOUNT, address(mintCreateInitializeController));
        erc721Rails.addPermission(Operations.MINT, address(mintCreateInitializeController));
        vm.stopPrank();

        mintParams = MintCreateInitializeController.MintParams({
            collection: address(erc721Rails),
            recipient: address(user),
            registry: address(erc6551Registry),
            accountProxy: address(accountProxy),
            salt: bytecodeSalt
        });
    }

    function test_mintAndCreateAccount() public {
        address mintedTBA;
        uint256 mintStart;
        assertFalse(mintedTBA.code.length > 0);

        vm.prank(owner);
        (mintedTBA, mintStart) = mintCreateInitializeController.mintAndCreateAccount(mintParams);
        assertTrue(mintedTBA.code.length > 0);

        // assert contract was created with expected bytecode
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(mintedTBA));
        bytes32 packedParams = bytes32(abi.encodePacked(params.accountGroup, params.subgroupId, params.index));
        assertEq(packedParams, bytecodeSalt);

        assertTrue(mintStart == 1);
    }

    function test_mintAndCreateAccountPermission() public {
        address mintedTBA;
        uint256 mintStart;

        // grant turnkey permission to create accounts
        vm.prank(owner);
        IPermissions(address(erc721Rails)).addPermission(Operations.MINT_PERMIT, turnkey);

        vm.prank(turnkey);
        (mintedTBA, mintStart) = mintCreateInitializeController.mintAndCreateAccount(mintParams);

        // assert contract was created with expected bytecode
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(address(mintedTBA));
        bytes32 packedParams = bytes32(abi.encodePacked(params.accountGroup, params.subgroupId, params.index));
        assertEq(packedParams, bytecodeSalt);

        assertTrue(mintStart == 1);
    }
}
