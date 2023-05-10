// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/modules/FixedETHPurchaseModule.sol";

// forge script script/modules/DeployFixedETHPurchaseModule.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
// forge verify-contract 0x928d70acd89cc4d18f7ac9d28cf77646ea42bd4a ./src/modules/FixedETHPurchaseModule.sol:FixedETHPurchaseModule $ETHERSCAN_API_KEY --chain-id 5
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();

        address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006; // personal wallet
        uint256 fee = 0.0007 ether;
        new FixedETHPurchaseModule(owner, fee);
        vm.stopBroadcast();
    }
}
