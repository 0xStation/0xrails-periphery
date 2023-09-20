// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
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
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

contract Deploy is ScriptUtils {
    /*=================
        ENVIRONMENT 
    =================*/

    // The following contracts will be deployed:
    MetadataRouter metadataRouterImpl;
    MetadataRouter metadataRouter; // proxy
    OnePerAddressGuard onePerAddressGuard;
    NFTMetadataRouterExtension nftMetadataRouterExtension;
    PayoutAddressExtension payoutAddressExtension;
    FeeManager feeManager;
    FreeMintModule freeMintModule;
    GasCoinPurchaseModule gasCoinPurchaseModule;
    StablecoinPurchaseModule stablecoinPurchaseModule;
    MembershipFactory membershipFactoryImpl;
    MembershipFactory membershipFactory; // proxy

    // uncomment all instances of `deployerPrivateKey` if using a private key in shell env var
    // uint256 deployerPrivateKey = vm.envUint("PK");

    function run() public {
        /*============
            CONFIG
        ============*/

        // `deployMetadataRouter()` params configuration
        // string memory defaultURI = "https://groupos.xyz/api/v1/contractMetadata";
        string memory defaultURI = "https://dev.groupos.xyz/api/v1/contractMetadata"; // goerli
        string[] memory routes = new string[](1);
        routes[0] = "token";
        string[] memory uris = new string[](1);
        // uris[0] = "https://groupos.xyz/api/v1/nftMetadata";
        uris[0] = "https://dev.groupos.xyz/api/v1/nftMetadata"; // goerli

        // `deployStablecoinPurchaseModule` params configuration
        uint8 decimals = 2;
        string memory currency = "USD";
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = 0xD478219fDca296699A6511f28BA93a265E3E9a1b; // goerli
        // stablecoins[0] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; // polygon
        // stablecoins[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // ethereum

        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast( /*deployerPrivateKey*/ );

        address owner = ScriptUtils.stationFounderSafe;
        
        string memory saltString = ScriptUtils.readSalt("salt");
        bytes32 salt = bytes32(bytes(saltString));

        // eventually we can just use ScriptUtils to read from deploys.json
        // address erc721Rails = 0x7c804b088109C23d9129366a8C069448A4b219F8; // goerli, polygon, mainnet
        address erc721Rails = 0xac06D8C535cb53F614d5C79809c778AB38343A63; // goerli, sepolia

        (metadataRouterImpl, metadataRouter) = deployMetadataRouter(owner, defaultURI, routes, uris, salt);
        onePerAddressGuard = deployOnePerAddressGuard(address(metadataRouter), salt);
        nftMetadataRouterExtension = deployNFTMetadataRouterExtension(address(metadataRouter), salt);
        payoutAddressExtension = deployPayoutAddressExtension(address(metadataRouter), salt);

        feeManager = FeeManager(deployFeeManager(owner, salt));
        freeMintModule = deployFreeMintModule(owner, address(feeManager), address(metadataRouter), salt);
        gasCoinPurchaseModule = deployGasCoinPurchaseModule(owner, address(feeManager), address(metadataRouter), salt);

        // using stablecoin 'environment' params above
        stablecoinPurchaseModule = deployStablecoinPurchaseModule(
            owner, address(feeManager), decimals, currency, stablecoins, address(metadataRouter), salt
        );

        (membershipFactoryImpl, membershipFactory) = deployMembershipFactory(owner, erc721Rails, salt);

        // missing: ExtensionBeacon

        vm.stopBroadcast();

        writeUsedSalt(
            saltString, string.concat("MetaDataRouterImpl @", Strings.toHexString(address(metadataRouterImpl)))
        );
        writeUsedSalt(saltString, string.concat("MetaDataRouterProxy @", Strings.toHexString(address(metadataRouter))));
        writeUsedSalt(
            saltString,
            string.concat("NFTMetadataRouterExtension @", Strings.toHexString(address(nftMetadataRouterExtension)))
        );
        writeUsedSalt(
            saltString, string.concat("PayoutAddressExtension @", Strings.toHexString(address(payoutAddressExtension)))
        );
        writeUsedSalt(saltString, string.concat("FeeManager @", Strings.toHexString(address(feeManager))));
        writeUsedSalt(saltString, string.concat("FreeMintModule @", Strings.toHexString(address(freeMintModule))));
        writeUsedSalt(
            saltString, string.concat("GasCoinPurchaseModule @", Strings.toHexString(address(gasCoinPurchaseModule)))
        );
        writeUsedSalt(
            saltString,
            string.concat("StablecoinPurchaseModule @", Strings.toHexString(address(stablecoinPurchaseModule)))
        );
        writeUsedSalt(
            saltString, string.concat("MembershipFactoryImpl @", Strings.toHexString(address(membershipFactoryImpl)))
        );
        writeUsedSalt(
            saltString, string.concat("MembershipFactoryProxy @", Strings.toHexString(address(membershipFactory)))
        );
    }

    function deployMetadataRouter(
        address _owner,
        string memory _defaultURI,
        string[] memory _routes,
        string[] memory _uris,
        bytes32 _salt
    ) internal returns (MetadataRouter _impl, MetadataRouter _proxy) {
        _impl = new MetadataRouter{salt: _salt}();

        bytes memory initData =
            abi.encodeWithSelector(MetadataRouter.initialize.selector, _owner, _defaultURI, _routes, _uris);
        _proxy = MetadataRouter(address(new ERC1967Proxy{salt: _salt}(address(_impl), initData)));
    }

    function deployOnePerAddressGuard(address _metadataRouter, bytes32 _salt) internal returns (OnePerAddressGuard) {
        return new OnePerAddressGuard{salt: _salt}(_metadataRouter);
    }

    function deployNFTMetadataRouterExtension(address _metadataRouter, bytes32 _salt)
        internal
        returns (NFTMetadataRouterExtension)
    {
        return new NFTMetadataRouterExtension{salt: _salt}(_metadataRouter);
    }

    function deployPayoutAddressExtension(address _metadataRouter, bytes32 _salt)
        internal
        returns (PayoutAddressExtension)
    {
        return new PayoutAddressExtension{salt: _salt}(_metadataRouter);
    }

    function deployFeeManager(address _owner, bytes32 _salt) internal returns (FeeManager) {
        uint120 _ethBaseFee = 1e15; // 0.001 ETH
        // uint120 polygonBaseFee = 2e18; // 2 MATIC
        uint120 _defaultBaseFee = 0;
        uint120 _defaultVariableFee = 500; // 5%

        return
            new FeeManager{salt: _salt}(_owner, _defaultBaseFee, _defaultVariableFee, _ethBaseFee, _defaultVariableFee);
    }

    function deployFreeMintModule(address _owner, address _feeManager, address _metadataRouter, bytes32 _salt)
        internal
        returns (FreeMintModule)
    {
        return new FreeMintModule{salt: _salt}(_owner, _feeManager, _metadataRouter);
    }

    function deployGasCoinPurchaseModule(address _owner, address _feeManager, address _metadataRouter, bytes32 _salt)
        internal
        returns (GasCoinPurchaseModule)
    {
        return new GasCoinPurchaseModule{salt: _salt}(_owner, _feeManager, _metadataRouter);
    }

    function deployStablecoinPurchaseModule(
        address _owner,
        address _feeManager,
        uint8 _decimals,
        string memory _currency,
        address[] memory _stablecoins,
        address _metadataRouter,
        bytes32 _salt
    ) internal returns (StablecoinPurchaseModule) {
        return
        new StablecoinPurchaseModule{salt: _salt}(_owner, _feeManager, _decimals, _currency, _stablecoins, _metadataRouter);
    }

    function deployMembershipFactory(address _owner, address _erc721Rails, bytes32 _salt)
        internal
        returns (MembershipFactory _impl, MembershipFactory _proxy)
    {
        _impl = new MembershipFactory{salt: _salt}();

        bytes memory initFactory = abi.encodeWithSelector(MembershipFactory.initialize.selector, _erc721Rails, _owner);
        _proxy = MembershipFactory(address(new ERC1967Proxy{salt: _salt}(address(_impl), initFactory)));
    }
}
