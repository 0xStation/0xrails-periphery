// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";
import {EIP712} from "openzeppelin-contracts/utils/cryptography/EIP712.sol";
import {ERC2771ContextInitializable} from "0xrails/lib/ERC2771/ERC2771ContextInitializable.sol";
import {ERC2771Forwarder} from "0xrails/lib/ERC2771/ERC2771Forwarder.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {MockAccountDeployer} from "lib/0xrails/test/lib/MockAccount.sol";
import {FreeMintController} from "src/membership/modules/FreeMintController.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";

contract ERC2771ContextInitializableTest is Test, MockAccountDeployer {
    ERC2771Forwarder public forwarder;
    ERC721Rails public ERC721RailsImpl;
    ERC721Rails public ERC721RailsProxy; // ERC1967 proxy wrapped in ERC721Rails for convenience

    FeeManager feeManager;
    FreeMintController freeMintController;

    uint256 public privateKey;
    uint256 public privateKey2;
    string public domainName;

    address public owner;
    string public name;
    string public symbol;
    bytes initData;

    address public from;
    address public recipient;
    uint48 deadline;
    bytes data1;
    bytes data2;
    bytes signature1;
    bytes signature2;
    ERC2771Forwarder.ForwardRequestData forwardRequestData1;
    ERC2771Forwarder.ForwardRequestData forwardRequestData2;

    bytes32 public constant FORWARD_REQUEST_TYPEHASH =
        keccak256(
            "ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,uint48 deadline,bytes data)"
        );
    bytes32 public DOMAIN_TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public VERSION_HASH;
    bytes32 public NAME_HASH;
    bytes32 public domainSeparator;

    // to store errors
    bytes err;

    function setUp() public {
        privateKey2 = 0xdeadbeef;
        from = vm.addr(privateKey2);
        recipient = createAccount();
        domainName = "Forwarder";
        forwarder = new ERC2771Forwarder(domainName);
        
        (, string memory _retName, string memory _retVersion,,,,) = EIP712(forwarder).eip712Domain();
        VERSION_HASH = keccak256(bytes(_retVersion));
        NAME_HASH = keccak256(bytes(_retName));
        domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPE_HASH, NAME_HASH, VERSION_HASH, block.chainid, address(forwarder))
        );

        // deploy and initialize erc721
        privateKey = 0xbeefEbabe;
        owner = vm.addr(privateKey);
        name = "Station";
        symbol = "STN";
        // include empty init data for setup
        initData = abi.encodeWithSelector(ERC721Rails.initialize.selector, owner, name, symbol, "", address(forwarder));

        ERC721RailsImpl = new ERC721Rails();
        ERC721RailsProxy = ERC721Rails(
            payable(
                address(
                    new ERC1967Proxy(
                    address(ERC721RailsImpl), 
                    initData
                    )
                )
            )
        );
        
        feeManager = new FeeManager(owner, 0, 0, 0, 0);
        freeMintController = new FreeMintController(owner, address(feeManager), address(forwarder));
        // grant mint permission to `from` address and controller so it can mint
        vm.startPrank(owner);
        ERC721RailsProxy.addPermission(Operations.MINT, from);
        ERC721RailsProxy.addPermission(Operations.MINT, address(freeMintController));
        vm.stopPrank();
    }

    function test_executeFromController() public {
        data1 = abi.encodeWithSelector(FreeMintController.mintTo.selector, address(ERC721RailsProxy), recipient);
        forwardRequestData1 = ERC2771Forwarder.ForwardRequestData({
            from: from,
            to: address(freeMintController),
            value: 0,
            gas: 1000000,
            deadline: type(uint48).max,
            data: data1,
            signature: ''
        });

        bytes32 valuesHash = keccak256(
            abi.encode(FORWARD_REQUEST_TYPEHASH, forwardRequestData1.from, forwardRequestData1.to, forwardRequestData1.value, forwardRequestData1.gas, forwarder.lastUsedNonce(owner, 0) + 1, forwardRequestData1.deadline, keccak256(forwardRequestData1.data))
        );

        bytes32 forwardRequestDataHash = ECDSA.toTypedDataHash(domainSeparator, valuesHash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey2, forwardRequestDataHash);
        bytes memory sig = abi.encodePacked(r, s, v);
        forwardRequestData1.signature = sig;

        // disable permits for collection
        vm.prank(owner);
        freeMintController.setUp(address(ERC721RailsProxy), false);

        forwarder.execute(forwardRequestData1);
        assertEq(ERC721RailsProxy.balanceOf(recipient), 1);
    }
}