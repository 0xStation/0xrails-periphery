// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {PublicFreeMintModule} from "src/modules/PublicFreeMintModule.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Plurigrid is Script {
    string public name = "Grid 0x00: A16Z Crypto";
    string public symbol = "0x00";

    address public owner = 0x016562aA41A8697720ce0943F003141f5dEAe006; // sym
    // address public owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog

    address public renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli
    // address public renderer = 0x9AE8391F311292c8E241DB576C6d528932B1939f; // polygon

    // address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;

    address public onePerAddress = 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7; // goerli
    // address public onePerAddress = 0xfD54A7a9E5df54872b07df99893CCD474C8f2b53; // polygon
    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    // address public membershipImpl = 0x1b8C7a6b778eedE6DB61a8e01922b6F350810aDE; // goerli
    // address public membershipImpl = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // polygon
    address public membershipImpl;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        membershipImpl = address(new Membership());
        address module = address(new PublicFreeMintModule(owner, 0.001 ether));

        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).init.selector, msg.sender, renderer, name, symbol);
        address proxy = address(new ERC1967Proxy(membershipImpl, initData));

        // config

        bytes memory permitModule = abi.encodeWithSelector(
            Permissions.permit.selector, module, operationPermissions(Permissions.Operation.MINT)
        );
        bytes memory guardMint =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.MINT, onePerAddress);
        bytes memory guardTransfer =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.TRANSFER, MAX_ADDRESS);

        bytes[] memory setupCalls = new bytes[](3);
        setupCalls[0] = permitModule;
        setupCalls[1] = guardMint;
        setupCalls[2] = guardTransfer;

        // make non-atomic batch call, using permission as owner to do anything
        Batch(proxy).batch(false, setupCalls);
        // transfer ownership to provided argument
        Permissions(proxy).transferOwnership(owner);

        vm.stopBroadcast();
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(Permissions.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}
