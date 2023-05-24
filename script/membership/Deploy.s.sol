// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import { Membership } from  "../../src/membership/Membership.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
        address renderer = 0x0DAb51C6d469001D31FfdE15Db9E539d8bAC4125;
        address membershipImpl = address(new Membership());

        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).init.selector, owner, renderer, "6551 Squad", "TBA");
        new ERC1967Proxy(membershipImpl, initData);
        vm.stopBroadcast();
    }
}
