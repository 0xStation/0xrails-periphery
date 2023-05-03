// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/membership/Membership.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address membership_proxy = 0x536a8af52440C60295CFA5176D5B62F399aD429b;
        address membershipV2Impl = address(new Membership());

        Membership proxy = Membership(membership_proxy);
        proxy.upgradeTo(membershipV2Impl);
        vm.stopBroadcast();
    }
}
