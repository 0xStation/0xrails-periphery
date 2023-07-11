// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";

contract UpdateURI is Script {
    function run() public {
        vm.startBroadcast();
        address renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E;
        // string memory baseURI = "https://members.station.express/api/v1/nftMetadata";
        string memory baseURI = "https://dev.station.express/api/v1/nftMetadata";

        Renderer(renderer).updateBaseURI(baseURI);
        vm.stopBroadcast();
    }
}
