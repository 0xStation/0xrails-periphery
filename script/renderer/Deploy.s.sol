// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        new Renderer(msg.sender, "https://token.station.express/api/v1/nftMetadata");
        vm.stopBroadcast();
    }
}
