// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {EthPurchaseModuleV2} from "src/membership/modules/EthPurchaseModuleV2.sol";
import {StablecoinPurchaseModuleV2} from "src/membership/modules/StablecoinPurchaseModuleV2.sol";
import {FreeMintModuleV2} from "src/membership/modules/FreeMintModuleV2.sol";

// forge script script/modules/DeployFixedETHPurchaseModule.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
// forge verify-contract 0x928d70acd89cc4d18f7ac9d28cf77646ea42bd4a ./src/modules/FixedETHPurchaseModule.sol:FixedETHPurchaseModule $ETHERSCAN_API_KEY --chain-id 5
contract DeployModules is Script {
    address owner = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d; // sym

    uint256 fee = 0.001 ether; // ethereum
    // uint256 fee = 2 ether; // polygon

    address FAKE = 0xD478219fDca296699A6511f28BA93a265E3E9a1b; // goerli
    // address USDC = 0x016562aA41A8697720ce0943F003141f5dEAe006; // goerli
    // address DAI = 0x016562aA41A8697720ce0943F003141f5dEAe006; // goerli

    function run() public {
        vm.startBroadcast();

        // new FreeMintModuleV2(owner, fee);
        // new EthPurchaseModuleV2(owner, fee);

        address[] memory stablecoins = new address[](1);
        stablecoins[0] = FAKE;
        new StablecoinPurchaseModuleV2(owner, fee, 2, "USD", stablecoins);

        vm.stopBroadcast();
    }
}
