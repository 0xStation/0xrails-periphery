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
        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
        // latest renderer as of 5.11.23
        // https://goerli.etherscan.io/address/0xc0935a7284859199c016Aa4F66704CEB501013E6
        address renderer = 0xC4748Fb528Bcf583144225e3F3d0b765B413383A;
        address membershipImpl = address(new Membership());

        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).initialize.selector, owner, renderer, "6551 Squad", "TBA");
        new ERC1967Proxy(membershipImpl, initData);
        vm.stopBroadcast();
    }
}
