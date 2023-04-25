// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Demo.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        new Demo(0x016562aA41A8697720ce0943F003141f5dEAe006, "Conner's frens", "CONNER", "");
    }
}
