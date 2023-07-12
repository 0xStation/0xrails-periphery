// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ModuleFee} from "src/lib/module/ModuleFee.sol";

// forge script script/modules/DeployFixedETHPurchaseModule.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
// forge verify-contract 0x928d70acd89cc4d18f7ac9d28cf77646ea42bd4a ./src/modules/FixedETHPurchaseModule.sol:FixedETHPurchaseModule $ETHERSCAN_API_KEY --chain-id 5
contract UpdateModuleFees is Script {
    address owner = 0x016562aA41A8697720ce0943F003141f5dEAe006; // sym

    uint256 newFee = 0.001 ether; // ethereum
    // uint256 fee = 2 ether; // polygon

    address free = 0x37CDd35d650c3f88C1E2F011a2d9FfE295f23132; // goerli
    address eth = 0x64FCaCfd9f94fA6e3e186593e86247E1Ab84B40d; // goerli
    address stablecoin = 0xBAfCE0738451666f43dD98Bb579D59F64a91DB2e; // goerli

    function run() public {
        vm.startBroadcast();

        ModuleFee(free).updateFee(newFee);
        ModuleFee(eth).updateFee(newFee);
        ModuleFee(stablecoin).updateFee(newFee);

        vm.stopBroadcast();
    }
}
