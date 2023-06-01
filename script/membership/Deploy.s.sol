// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/lib/renderer/Renderer.sol";
import {Batch} from "src/lib/Batch.sol";
import {Membership} from "src/membership/Membership.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006; // sym
        // address owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog
        address renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli
        // address renderer = 0x9AE8391F311292c8E241DB576C6d528932B1939f; // polygon
        // address paymentCollector = owner;

        string memory name = "Lobby3";
        string memory symbol = "LOBBY";

        // address turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
        // address onePerAddress = 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7; // goerli
        // address onePerAddress = 0xfD54A7a9E5df54872b07df99893CCD474C8f2b53; // polygon
        // address MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

        address membershipImpl = 0x1b8C7a6b778eedE6DB61a8e01922b6F350810aDE; // goerli
        // address membershipImpl = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // polygon
        // address membershipImpl = address(new Membership());

        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).init.selector, msg.sender, renderer, name, symbol);
        address proxy = address(new ERC1967Proxy(membershipImpl, initData));

        // config

        bytes memory permitTurnkey = abi.encodeWithSelector(
            Permissions.permit.selector,
            0xBb942519A1339992630b13c3252F04fCB09D4841,
            permissionsValue(Permissions.Operation.MINT, membershipImpl)
        );
        bytes memory guardMint = abi.encodeWithSelector(
            Permissions.guard.selector, Permissions.Operation.MINT, 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7
        );
        bytes memory guardTransfer = abi.encodeWithSelector(
            Permissions.guard.selector, Permissions.Operation.TRANSFER, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF
        );

        bytes[] memory setupCalls = new bytes[](3);
        setupCalls[0] = permitTurnkey;
        setupCalls[1] = guardMint;
        setupCalls[2] = guardTransfer;

        // make non-atomic batch call, using permission as owner to do anything
        Batch(proxy).batch(false, setupCalls);
        // transfer ownership to provided argument
        Permissions(proxy).transferOwnership(owner);

        vm.stopBroadcast();
    }

    function permissionsValue(Permissions.Operation operation, address membershipImpl) public pure returns (bytes32) {
        Permissions.Operation[] memory operations = new Permissions.Operation[](1);
        operations[0] = operation;
        return Permissions(membershipImpl).permissionsValue(operations);
    }
}
