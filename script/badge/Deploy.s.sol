// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/badge/Badge.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
        // address renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli
        address renderer = 0x9AE8391F311292c8E241DB576C6d528932B1939f; // polygon
        string memory name = "Salon";
        string memory symbol = "OC.SALON";

        address badgeImpl = address(new Badge());

        bytes memory initData = abi.encodeWithSelector(Badge(badgeImpl).init.selector, owner, renderer, name, symbol);
        address badgeProxy = address(new ERC1967Proxy(badgeImpl, initData));

        vm.stopBroadcast();
    }
}
