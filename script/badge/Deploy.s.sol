// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/badge/Badge.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
        address renderer = 0x0DAb51C6d469001D31FfdE15Db9E539d8bAC4125; // polygon
        address badgeImpl = address(new Badge());

        bytes memory initData = abi.encodeWithSelector(
            Badge(badgeImpl).init.selector, owner, renderer, "Weekly Community Calls", "DEVCALLS"
        );
        address badgeProxy = address(new ERC1967Proxy(badgeImpl, initData));

        vm.stopBroadcast();
    }
}
