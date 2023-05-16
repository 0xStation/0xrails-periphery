// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/membership/Membership.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address delayed_renderer = 0x4377183d9f9376E7DA270c3d103F0250A5ec803f;
        address membershipImpl = address(new Membership());

        bytes memory initData = abi.encodeWithSelector(
            Membership(membershipImpl).initialize.selector,
            msg.sender,
            delayed_renderer,
            "Friends of Station",
            "FRIENDS"
        );
        new ERC1967Proxy(membershipImpl, initData);
        vm.stopBroadcast();
    }
}
