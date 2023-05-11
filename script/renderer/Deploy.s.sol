// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
        new Renderer(owner, "https://tokenbound.station.express/api/v1/nftMetadata");
        vm.stopBroadcast();
    }
}
