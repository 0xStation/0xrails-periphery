// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address owner = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
        string memory baseURI = "https://members.station.express/api/v1/nftMetadata";

        new Renderer(owner, baseURI);
        vm.stopBroadcast();
    }
}
