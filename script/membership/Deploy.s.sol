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
import {NFTMetadataRouterExtension} from "../../src/membership/extensions/NFTMetadataRouter/NFTMetadataRouterExtension.sol";
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
        address[] memory stablecoins = new address[](0);

        return address(new StablecoinPurchaseModule(owner, feeManager, decimals, currency, stablecoins, metadataRouter));
    }

    function deployMetadataRouter() internal returns (address) {
        string memory baselineURI = "https://groupos.xyz/api/v1/nftMetadata";
        string[] memory contractTypes = new string[](0);
        string[] memory uris = new string[](0);

        return address(new MetadataRouter(owner, baselineURI, contractTypes, uris));
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

    function deployMembershipFactory() internal returns (address) {
        // address erc721Mage = 0xCAde55923e5106bb6d8D67d914e5BcB8444cDFb3; // goerli
        address erc721Mage = 0x72B7817075AC3263783296f33c8F053e848594a3; // polygon
        address membershipFactoryImpl = address(new MembershipFactory());

        bytes memory initFactory =
            abi.encodeWithSelector(MembershipFactory(membershipFactoryImpl).initialize.selector, erc721Mage, owner);
        return address(new ERC1967Proxy(membershipFactoryImpl, initFactory));
    }
}
