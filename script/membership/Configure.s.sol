// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/membership/Membership.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
        address turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
        address onePerAddress = 0xfD54A7a9E5df54872b07df99893CCD474C8f2b53;
        address MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
        address proxy = 0x48c0C83f7ff34927C7A74Aa5fAD15d95F34E6eB0;

        bytes[] memory setupCalls = new bytes[](3);

        // set turnkey control
        // set mint guard
        // set nontransferable

        // bytes memory batchData = abi.encodeWithSelector(Membership(membershipImpl).batch.selector, true, setupCalls);

        vm.stopBroadcast();
    }
}
