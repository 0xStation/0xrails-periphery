// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/membership/MembershipFactory.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// DEPLOY SCRIPT (goerli)
// forge script script/membership/DeployFactory.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast

// VERIFY SCRIPT (goerli)
// forge verify-contract 0xC4B66df5F31f61e685D74A34Dacf0216CDCf19aD ./src/membership/MembershipFactory.sol:MembershipFactory $ETHERSCAN_API_KEY --chain-id 5
contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // address membershipImpl = address(new Membership());
        address membershipImpl = 0xadBc7EC633B78dc4407215D56Eb0861dD7c51431;
        new MembershipFactory(membershipImpl, msg.sender);
        vm.stopBroadcast();
    }
}
