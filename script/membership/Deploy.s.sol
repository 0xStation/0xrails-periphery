// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {FeeManager} from "../../src/lib/module/FeeManager.sol";
import {FreeMintModule} from "../../src/membership/modules/FreeMintModule.sol";
import {GasCoinPurchaseModule} from "../../src/membership/modules/GasCoinPurchaseModule.sol";
import {StablecoinPurchaseModule} from "../../src/membership/modules/StablecoinPurchaseModule.sol";
import {MetadataRouter} from "../../src/metadataRouter/MetadataRouter.sol";
import {OnePerAddressGuard} from "../../src/membership/guards/OnePerAddressGuard.sol";
import {NFTMetadataRouterExtension} from
    "../../src/membership/extensions/NFTMetadataRouter/NFTMetadataRouterExtension.sol";
import {PayoutAddressExtension} from "../../src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {MembershipFactory} from "../../src/membership/factory/MembershipFactory.sol";

contract Deploy is Script {
    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;

    address public owner = sym;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        /// @dev first deploy ERC721Mage from the mage repo and update the address in `deployMembershipFactory`!

        address metadataRouter = deployMetadataRouter();
        deployOnePerAddressGuard(metadataRouter);
        deployNFTMetadataRouterExtension(metadataRouter);
        deployPayoutAddressExtension(metadataRouter);

        address feeManager = deployFeeManager();
        deployFreeMintModule(feeManager, metadataRouter);
        deployGasCoinPurchaseModule(feeManager, metadataRouter);
        deployStablecoinPurchaseModule(feeManager, metadataRouter);

        deployMembershipFactory();

        // missing: ExtensionBeacon

        vm.stopBroadcast();
    }

    function deployMetadataRouter() internal returns (address) {
        // string memory defaultURI = "https://groupos.xyz/api/v1/contractMetadata";
        string memory defaultURI = "https://dev.groupos.xyz/api/v1/contractMetadata"; // goerli
        string[] memory routes = new string[](1);
        routes[0] = "token";
        string[] memory uris = new string[](1);
        // uris[0] = "https://groupos.xyz/api/v1/nftMetadata";
        uris[0] = "https://dev.groupos.xyz/api/v1/nftMetadata"; // goerli

        address metadataRouterImpl = address(new MetadataRouter());

        bytes memory initData = abi.encodeWithSelector(
            MetadataRouter(metadataRouterImpl).initialize.selector, owner, defaultURI, routes, uris
        );
        return address(new ERC1967Proxy(metadataRouterImpl, initData));
    }

    function deployOnePerAddressGuard(address metadataRouter) internal returns (address) {
        return address(new OnePerAddressGuard(metadataRouter));
    }

    function deployNFTMetadataRouterExtension(address metadataRouter) internal returns (address) {
        return address(new NFTMetadataRouterExtension(metadataRouter));
    }

    function deployPayoutAddressExtension(address metadataRouter) internal returns (address) {
        return address(new PayoutAddressExtension(metadataRouter));
    }

    function deployFeeManager() internal returns (address) {
        uint120 ethBaseFee = 1e15; // 0.001 ETH
        // uint120 polygonBaseFee = 2e18; // 2 MATIC
        uint120 defaultBaseFee = 0;
        uint120 defaultVariableFee = 500; // 5%

        return address(new FeeManager(owner, defaultBaseFee, defaultVariableFee, ethBaseFee, defaultVariableFee));
    }

    function deployFreeMintModule(address feeManager, address metadataRouter) internal returns (address) {
        return address(new FreeMintModule(owner, feeManager, metadataRouter));
    }

    function deployGasCoinPurchaseModule(address feeManager, address metadataRouter) internal returns (address) {
        return address(new GasCoinPurchaseModule(owner, feeManager, metadataRouter));
    }

    function deployStablecoinPurchaseModule(address feeManager, address metadataRouter) internal returns (address) {
        uint8 decimals = 2;
        string memory currency = "USD";
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = 0xD478219fDca296699A6511f28BA93a265E3E9a1b; // goerli
        // stablecoins[0] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; // polygon
        // stablecoins[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // ethereum

        return address(new StablecoinPurchaseModule(owner, feeManager, decimals, currency, stablecoins, metadataRouter));
    }

    function deployMembershipFactory() internal returns (address) {
        address erc721Mage = 0x7c804b088109C23d9129366a8C069448A4b219F8; // goerli, polygon, mainnet
        address membershipFactoryImpl = address(new MembershipFactory());

        bytes memory initFactory =
            abi.encodeWithSelector(MembershipFactory(membershipFactoryImpl).initialize.selector, erc721Mage, owner);
        return address(new ERC1967Proxy(membershipFactoryImpl, initFactory));
    }
}
