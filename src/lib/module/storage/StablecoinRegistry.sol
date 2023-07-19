// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/// @title Station Network Stablecoin Registry Contract
/// @author 👦🏻👦🏻.eth

/// @dev This contract stores contract addresses for all relevant stablecoin tokens supported by Station Network
/// @dev All addresses are stored as constants in runtime bytecode rather than storage to substantially save gas (no SLOADs)

contract StablecoinRegistry is Ownable {

    uint8 public constant usdcKey = 1;
    uint8 public constant usdtKey = 2;
    uint8 public constant daiKey = 3;

    /*=============
        MAINNET
    =============*/

    // Obtained from Circle docs: https://www.circle.com/en/usdc/developers
    address public constant usdc1 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // Obtained from Tether docs: https://tether.to/en/supported-protocols/
    address public constant usdt1 = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    // Obtained from MakerDAO's onchain registry of contract deployments, visible as JSON here: https://chainlog.makerdao.com/api/mainnet/active.json
    address public constant dai1 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    /*=============
        POLYGON
    =============*/

    // Obtained from Circle docs: https://www.circle.com/en/usdc-multichain/polygon
    address public constant usdc137 = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    // Obtained from Tether docs: https://tether.to/en/supported-protocols/
    address public constant usdt137 = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    // Obtained from Hop Bridge DAI token contract: https://app.hop.exchange
    address public constant dai137 = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

    /*=============
        GOERLI
    =============*/

    // Obtained from Circle docs: https://developers.circle.com/developer/docs/usdc-on-testnet
    address public constant usdc5 = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
    // Tether does not provide an official USDT contract on Goerli but this one is deployed and managed by Linea: https://faucet.goerli.linea.build/
    address public constant usdt5 = 0xfad6367E97217cC51b4cd838Cc086831f81d38C2;
    // Obtained from MakerDAO's onchain registry of contract deployments, visible as JSON here: https://chainlog.makerdao.com/api/goerli/active.json
    address public constant dai5 = 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;

    function getAddress(uint8 key) public view returns (address stable) {
        uint256 chainId = block.chainid;
        address[] memory stablecoins = new address[](4);
        // stablecoins[0] need not be set since it implicitly == address(0) without initialization

        if (chainId == 1) {
            stablecoins[1] = usdc1;
            stablecoins[2] = usdt1;
            stablecoins[3] = dai1;

            return stablecoins[key];
        } else if (chainId == 137) {
            stablecoins[1] = usdc137;
            stablecoins[2] = usdt137;
            stablecoins[3] = dai137;

            return stablecoins[key];
        } else if (chainId == 5) {
            stablecoins[1] = usdc5;
            stablecoins[2] = usdt5;
            stablecoins[3] = dai5;

            return stablecoins[key];
        }
    }
}