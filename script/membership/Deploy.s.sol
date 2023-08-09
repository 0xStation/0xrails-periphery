// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {FeeManager} from "../../src/lib/module/FeeManager.sol";
import {FreeMintModule} from "../../src/v2/membership/modules/FreeMintModule.sol";
import {GasCoinPurchaseModule} from "../../src/v2/membership/modules/GasCoinPurchaseModule.sol";
import {StablecoinPurchaseModule} from "../../src/v2/membership/modules/StablecoinPurchaseModule.sol";
import {MetadataRouter} from "../../src/v2/metadataRouter/MetadataRouter.sol";
import {MetadataURIExtension} from "../../src/v2/membership/extensions/MetadataURI/MetadataURIExtension.sol";
import {PayoutAddressExtension} from "../../src/v2/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {MembershipFactory} from "../../src/v2/membership/MembershipFactory.sol";

contract Deploy is Script {
    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;

    address public owner = sym;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        /// @dev first deploy ERC721Mage from the mage repo and update the address in `deployMembershipFactory`!

        address feeManager = deployFeeManager(owner);
        address freeMintModule = deployFreeMintModule(owner, feeManager);
        address gasCoinPurchaseModule = deployGasCoinPurchaseModule(owner, feeManager);
        address stablecoinPurchaseModule = deployStablecoinPurchaseModule(owner, feeManager);

        address metadataRouter = deployMetadataRouter(owner);
        address metadataURIExtension = deployMetadataURIExtension(metadataRouter);
        address payoutAddressExtension = deployPayoutAddressExtension(metadataRouter);

        address membershipFactory = deployMembershipFactory(owner);

        // missing: OnePerAddressGuard, ExtensionBeacon

        vm.stopBroadcast();
    }

    function deployFeeManager(address owner) internal returns (address) {
        FeeManager.Fees memory baselineFees = FeeManager.Fees(FeeManager.FeeSetting.Set, 0, 500); // 0 base, 5% variable
        FeeManager.Fees memory ethFees = FeeManager.Fees(FeeManager.FeeSetting.Set, 1e15, 500); // 0.001 base, 5% variable
        // FeeManager.Fees memory polygonFees = FeeManager.Fees(FeeManager.FeeSetting.Set, 2e18, 500); // 2 base, 5% variable

        return address(new FeeManager(owner, baselineFees, ethFees));
    }

    function deployFreeMintModule(address owner, address feeManager) internal returns (address) {
        return address(new FreeMintModule(owner, feeManager));
    }

    function deployGasCoinPurchaseModule(address owner, address feeManager) internal returns (address) {
        return address(new GasCoinPurchaseModule(owner, feeManager));
    }

    function deployStablecoinPurchaseModule(address owner, address feeManager) internal returns (address) {
        uint8 decimals = 2;
        string memory currency = "USD";
        address[] memory stablecoins = new address[](0);

        return address(new StablecoinPurchaseModule(owner, feeManager, decimals, currency, stablecoins));
    }

    function deployMetadataRouter(address owner) internal returns (address) {
        string memory baselineURI = "https://dev.station.express/api/v1/nftMetadata";
        string[] memory contractTypes = new string[](0);
        string[] memory uris = new string[](0);

        return address(new MetadataRouter(owner, baselineURI, contractTypes, uris));
    }

    function deployMetadataURIExtension(address metadataRouter) internal returns (address) {
        return address(new MetadataURIExtension(metadataRouter));
    }

    function deployPayoutAddressExtension(address metadataRouter) internal returns (address) {
        return address(new PayoutAddressExtension(metadataRouter));
    }

    function deployMembershipFactory(address owner) internal returns (address) {
        address erc721Mage = 0xCAde55923e5106bb6d8D67d914e5BcB8444cDFb3; // goerli
        address membershipFactoryImpl = address(new MembershipFactory());

        bytes memory initFactory =
            abi.encodeWithSelector(MembershipFactory(membershipFactoryImpl).initialize.selector, erc721Mage, owner);
        return address(new ERC1967Proxy(membershipFactoryImpl, initFactory));
    }
}
