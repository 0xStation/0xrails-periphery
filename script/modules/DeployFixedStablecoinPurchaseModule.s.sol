// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/modules/FixedStablecoinPurchaseModule.sol";

// forge script script/modules/DeployFixedStablecoinPurchaseModule.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
// forge verify-contract 0x5ea0ff4e291939cbaac4a89d0dd58852e109b10d ./src/modules/FixedStablecoinPurchaseModule.sol:FixedStablecoinPurchaseModule $ETHERSCAN_API_KEY --chain-id 5
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        address owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog wallet
        uint256 fee = 0.0007 ether;
        new FixedStablecoinPurchaseModule(owner, fee, "USD", 2);
        vm.stopBroadcast();
    }
}