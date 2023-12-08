// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PermitMintController} from "src/token/controller/PermitMintController.sol";
import {Test} from "forge-std/Test.sol";
import {PermitController} from "src/lib/module/PermitController.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {ERC20Rails} from "0xrails/cores/ERC20/ERC20Rails.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";

contract PermitMintControllerTest is Test, PermitMintController(address(0x0)) { // forwarder not necessary
    PermitMintController public permitMintController;
    FeeManager public feeManager;
    ERC20Rails public erc20Impl;
    ERC20Rails public erc20Proxy;

    address public owner;
    uint256 public somePK;
    address public someSigner;
    address public collection;
    address public recipient;
    uint256 public amount;

    bytes32 public GRANT_TYPE_HASH = keccak256("Permit(address sender,uint48 expiration,uint256 nonce,bytes data)");
    bytes32 public DOMAIN_TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public VERSION_HASH = keccak256("0.0.1");
    bytes32 public NAME_HASH = keccak256("GroupOS");

    // uint256 public goerliFork;
    // string GOERLI_RPC_URL = vm.envString("$GOERLI_RPC_URL");

    function setUp() public {
        // FORKING
        // goerliFork = vm.createFork(GOERLI_RPC_URL);
        // vm.selectFork(goerliFork);
        // permitMintController = 0x8E019DfdA444743CA58065bd9b24Bd569b61fa75;
        // collection = 0x8D007613435453041ec6d03E87a90117507065D0;

        // LOCAL
        owner = address(420);
        somePK = 69;
        someSigner = vm.addr(somePK);

        // deploy infra
        feeManager = new FeeManager(owner, 0, 0, 0, 0);
        permitMintController = new PermitMintController();

        // deploy collection & assign for convenience
        erc20Impl = new ERC20Rails();
        erc20Proxy = ERC20Rails(payable(address(new ERC1967Proxy(address(erc20Impl), bytes("")))));
        erc20Proxy.initialize(owner, "", "", "");
        collection = address(erc20Proxy);

        // add mint permission to permitMintController & someSigner
        vm.startPrank(owner);
        IPermissions(address(erc20Proxy)).addPermission(Operations.MINT, address(permitMintController));
        IPermissions(address(erc20Proxy)).addPermission(Operations.MINT_PERMIT, someSigner);
        recipient = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
        amount = 10;
        vm.stopPrank();
    }

    function test_callWithPermitERC20() public {
        // FORKING
        // Permit memory permit = Permit({
        //     signer: 0xBb942519A1339992630b13c3252F04fCB09D4841,
        //     sender: address(0x0),
        //     expiration: 1697820221,
        //     nonce: 1,
        //     data: hex'ef9bcb270000000000000000000000008d007613435453041ec6d03e87a90117507065d0000000000000000000000000e7affdb964178261df49b86bfdba78e9d768db6d000000000000000000000000000000000000000000000000000000000000000a',
        //     signature: hex'5c2599dc721d8c89ea09da1f922a7ac36ae2c4ebdec9d9802e6671d3d240619a2bcb35ac40cb72250ef2a62b614f7562cb26a2c1501e9068be89249add5b323c1b'
        // });

        // bytes memory mintToCall = abi.encodeWithSignature("mintTo(address,address,uint256)", collection, recipient, amount);
        // (bool r, ) = permitMintController.call(mintToCall);
        // require(r);

        // LOCAL
        bytes memory mintToCall =
            abi.encodeWithSelector(PermitMintController.mintToERC20.selector, collection, recipient, amount);
        Permit memory permit = Permit({
            signer: someSigner,
            sender: address(0x0),
            expiration: type(uint48).max,
            nonce: 1,
            data: mintToCall,
            signature: ""
        });
        bytes32 valuesHash = keccak256(
            abi.encode(GRANT_TYPE_HASH, permit.sender, permit.expiration, permit.nonce, keccak256(permit.data))
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPE_HASH, NAME_HASH, VERSION_HASH, block.chainid, address(permitMintController))
        );

        bytes32 permitHash = ECDSA.toTypedDataHash(domainSeparator, valuesHash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(somePK, permitHash);
        bytes memory sig = abi.encodePacked(r, s, v);
        permit.signature = sig;

        PermitController(address(permitMintController)).callWithPermit(permit);
    }

    function test_callWithPermitERC721() public {
        // FORKING
        // Permit memory permit = Permit({
        //     signer: 0xBb942519A1339992630b13c3252F04fCB09D4841,
        //     sender: address(0x0),
        //     expiration: 1697820221,
        //     nonce: 1,
        //     data: hex'ef9bcb270000000000000000000000008d007613435453041ec6d03e87a90117507065d0000000000000000000000000e7affdb964178261df49b86bfdba78e9d768db6d000000000000000000000000000000000000000000000000000000000000000a',
        //     signature: hex'5c2599dc721d8c89ea09da1f922a7ac36ae2c4ebdec9d9802e6671d3d240619a2bcb35ac40cb72250ef2a62b614f7562cb26a2c1501e9068be89249add5b323c1b'
        // });

        // bytes memory mintToCall = abi.encodeWithSignature("mintTo(address,address,uint256)", collection, recipient, amount);
        // (bool r, ) = permitMintController.call(mintToCall);
        // require(r);

        // LOCAL
        bytes memory mintToCall =
            abi.encodeWithSelector(PermitMintController.mintToERC721.selector, collection, recipient, amount);
        Permit memory permit = Permit({
            signer: someSigner,
            sender: address(0x0),
            expiration: type(uint48).max,
            nonce: 1,
            data: mintToCall,
            signature: ""
        });
        bytes32 valuesHash = keccak256(
            abi.encode(GRANT_TYPE_HASH, permit.sender, permit.expiration, permit.nonce, keccak256(permit.data))
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPE_HASH, NAME_HASH, VERSION_HASH, block.chainid, address(permitMintController))
        );

        bytes32 permitHash = ECDSA.toTypedDataHash(domainSeparator, valuesHash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(somePK, permitHash);
        bytes memory sig = abi.encodePacked(r, s, v);
        permit.signature = sig;

        PermitController(address(permitMintController)).callWithPermit(permit);
    }
}
