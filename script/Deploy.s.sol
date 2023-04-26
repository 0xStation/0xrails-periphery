// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/lib/renderer/Renderer.sol";
import "../src/badge/Badge.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;

        // address renderer = address(new Renderer(owner, "https://token.station.express/api/v1/nftMetadata"));
        // address badgeImpl = address(new Badge());

        // address badgeImpl = 0xe3c8a875D02F78C0E7F887599ad5e7fc2C33da02;
        // address badgeProxy = address(new ERC1967Proxy(badgeImpl, ""));

        address badgeProxy = 0xf611ddA769F29BB0d76B2780647f224d89E5194D;
        // address renderer = 0xadd4a6bBb15B27dAb50fd3382a1C68F8BcE51cd1;
        // Badge(badgeProxy).init(owner, renderer, "Friends of Station", "FRIENDS");
        Badge(badgeProxy).transferOwnership(0xBb942519A1339992630b13c3252F04fCB09D4841);
    }
}
