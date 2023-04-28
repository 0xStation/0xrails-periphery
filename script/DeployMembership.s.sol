// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/lib/renderer/Renderer.sol";
import "../src/membership/Membership.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // can probably reuse the same renderer between 721 and 1155?
        address renderer = address(new Renderer(msg.sender, "https://token.station.express/api/v1/nftMetadata"));
        address membershipImpl = address(new Membership());

        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).initialize.selector, msg.sender, renderer, "Friends of Station", "FRIENDS");
        address membershipProxy = address(new ERC1967Proxy(membershipImpl, initData));
        vm.stopBroadcast();
    }
}
