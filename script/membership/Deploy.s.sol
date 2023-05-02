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
        address frog_personal = 0x65A3870F48B5237f27f674Ec42eA1E017E111D63;
        // latest renderer as of 4.28.23
        // https://goerli.etherscan.io/address/0xbe38029bfc6641f32d42f5c01c4332c7fcdc5af9
        address renderer = 0xBE38029BFC6641f32d42F5C01c4332C7fCDC5Af9;
        address membershipImpl = address(new Membership());

        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).initialize.selector, frog_personal, renderer, "Friends of Station", "FRIENDS");
        new ERC1967Proxy(membershipImpl, initData);
        vm.stopBroadcast();
    }
}
