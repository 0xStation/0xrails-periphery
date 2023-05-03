// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/DelayedRevealRenderer.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        string memory preRevealedContentHash = "Y9UUu06gXVKAo0FVuQME961OsGtctMcGzfroB94Qiig";
        string memory ARWeavebaseURI = "ar://";
        new DelayedRevealRenderer(msg.sender, ARWeavebaseURI, preRevealedContentHash);
        vm.stopBroadcast();
    }
}
