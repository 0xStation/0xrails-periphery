// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/DelayedRevealRenderer.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        string memory ARWeavebaseURI = "https://arweave.net/ubzo5fhIAPutLVa7Gj4cYKwhiwzU8pu1wzP3cbcjbXY/";
        new DelayedRevealRenderer(msg.sender);
        vm.stopBroadcast();
    }
}
