// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {FeeManager} from "../../src/lib/module/FeeManager.sol";
import {FreeMintController} from "../../src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "../../src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "../../src/membership/modules/StablecoinPurchaseController.sol";
import {MetadataRouter} from "../../src/metadataRouter/MetadataRouter.sol";
import {OnePerAddressGuard} from "../../src/membership/guards/OnePerAddressGuard.sol";
import {NFTMetadataRouterExtension} from
    "../../src/membership/extensions/NFTMetadataRouter/NFTMetadataRouterExtension.sol";
import {PayoutAddressExtension} from "../../src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {ITokenFactory} from "../../src/factory/ITokenFactory.sol";
import {TokenFactory} from "../../src/factory/TokenFactory.sol";
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
    FreeMintController freeMintModule;
    GasCoinPurchaseController gasCoinPurchaseController;
    StablecoinPurchaseController stablecoinPurchaseController;
    TokenFactory tokenFactoryImpl;
    TokenFactory tokenFactory; // proxy

    function run() public {
        /*============
            CONFIG
        ============*/

        // `deployStablecoinPurchaseController` params configuration
        uint8 decimals = 2;
        string memory currency = "USD";
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = 0xD478219fDca296699A6511f28BA93a265E3E9a1b; // goerli
        // stablecoins[0] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; // polygon
        // stablecoins[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // ethereum

        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        address owner = ScriptUtils.stationFounderSafe;
        
        string memory saltString = ScriptUtils.readSalt("salt");
        bytes32 salt = bytes32(bytes(saltString));

        // eventually we can just use ScriptUtils to read from deploys.json
        // address erc721Rails = 0x7c804b088109C23d9129366a8C069448A4b219F8; // goerli, polygon, mainnet
        // address erc721Rails = 0xac06D8C535cb53F614d5C79809c778AB38343A63; // goerli, sepolia
        address erc721Rails = 0xA03a52b4C8D0C8C64c540183447494C25F590e20; // Linea

        // `MetadataRouter::initialize(owner, defaultURI, routes, uris)` params configuration
        string memory defaultURI = "https://groupos.xyz/api/v1/contractMetadata";
        string[] memory routes = new string[](1);
        routes[0] = "token";
        string[] memory uris = new string[](1);
        uris[0] = "https://groupos.xyz/api/v1/nftMetadata";
        bytes memory metadataRouterInitData =
            abi.encodeWithSelector(MetadataRouter.initialize.selector, owner, defaultURI, routes, uris);
        
        // `TokenFactory::initialize(erc721Rails, owner)` params configuration
        bytes memory tokenFactoryInitData = abi.encodeWithSelector(TokenFactory.initialize.selector, erc721Rails, owner);

        // begin deployments
        (metadataRouterImpl, metadataRouter) = deployMetadataRouter(salt);
        (tokenFactoryImpl, tokenFactory) = deployTokenFactory(salt);

        onePerAddressGuard = deployOnePerAddressGuard(address(metadataRouter), salt);
        nftMetadataRouterExtension = deployNFTMetadataRouterExtension(address(metadataRouter), salt);
        payoutAddressExtension = deployPayoutAddressExtension(address(metadataRouter), salt);

        feeManager = FeeManager(deployFeeManager(owner, salt));
        freeMintModule = deployFreeMintController(owner, address(feeManager), address(metadataRouter), salt);
        gasCoinPurchaseController = deployGasCoinPurchaseController(owner, address(feeManager), address(metadataRouter), salt);

        // using stablecoin 'environment' params above
        stablecoinPurchaseController = deployStablecoinPurchaseController(
            owner, address(feeManager), decimals, currency, stablecoins, address(metadataRouter), salt
        );

        // After deployments, format Multicall3 calls and execute it from FounderSafe as module sender 
        Call3 memory metadataRouterInitCall = 
            Call3({
                target: address(metadataRouter),
                allowFailure: false,
                callData: metadataRouterInitData
            });
        Call3 memory tokenFactoryInitCall = 
            Call3({
                target: address(tokenFactory),
                allowFailure: false,
                callData: tokenFactoryInitData
            });
        Call3[] memory calls = new Call3[](2);
        calls[0] = metadataRouterInitCall;
        calls[1] = tokenFactoryInitCall;
        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(0));` using 0 ETH value & Operation == CALL
        bytes memory safeCall = abi.encodeWithSignature("execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(0));
        owner.call(safeCall);

        // missing: ExtensionBeacon

        vm.stopBroadcast();

        writeUsedSalt(
            saltString, string.concat("MetaDataRouterImpl @", Strings.toHexString(address(metadataRouterImpl)))
        );
        writeUsedSalt(saltString, string.concat("MetaDataRouterProxy @", Strings.toHexString(address(metadataRouter))));
        writeUsedSalt(
            saltString, string.concat("TokenFactoryImpl @", Strings.toHexString(address(tokenFactoryImpl)))
        );
        writeUsedSalt(
            saltString, string.concat("TokenFactoryProxy @", Strings.toHexString(address(tokenFactory)))
        );
        writeUsedSalt(
            saltString,
            string.concat("NFTMetadataRouterExtension @", Strings.toHexString(address(nftMetadataRouterExtension)))
        );
        writeUsedSalt(
            saltString, string.concat("PayoutAddressExtension @", Strings.toHexString(address(payoutAddressExtension)))
        );
        writeUsedSalt(saltString, string.concat("FeeManager @", Strings.toHexString(address(feeManager))));
        writeUsedSalt(saltString, string.concat("FreeMintController @", Strings.toHexString(address(freeMintModule))));
        writeUsedSalt(
            saltString, string.concat("GasCoinPurchaseController @", Strings.toHexString(address(gasCoinPurchaseController)))
        );
        writeUsedSalt(
            saltString,
            string.concat("StablecoinPurchaseController @", Strings.toHexString(address(stablecoinPurchaseController)))
        );
    }

    function deployMetadataRouter(bytes32 _salt) internal returns (MetadataRouter _impl, MetadataRouter _proxy) {
        _impl = new MetadataRouter{salt: _salt}();
        _proxy = MetadataRouter(address(new ERC1967Proxy{salt: _salt}(address(_impl), '')));
    }

    function deployTokenFactory(bytes32 _salt) internal returns (TokenFactory _impl, TokenFactory _proxy) {
        _impl = new TokenFactory{salt: _salt}();
        _proxy = TokenFactory(address(new ERC1967Proxy{salt: _salt}(address(_impl), '')));
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
        uint120 _defaultBaseFee = 0;
        uint120 _defaultVariableFee = 500; // 5%

        return
            new FeeManager{salt: _salt}(_owner, _defaultBaseFee, _defaultVariableFee, _ethBaseFee, _defaultVariableFee);
    }

    function deployFreeMintController(address _owner, address _feeManager, address _metadataRouter, bytes32 _salt)
        internal
        returns (FreeMintController)
    {
        return new FreeMintController{salt: _salt}(_owner, _feeManager, _metadataRouter);
    }

    function deployGasCoinPurchaseController(address _owner, address _feeManager, address _metadataRouter, bytes32 _salt)
        internal
        returns (GasCoinPurchaseController)
    {
        return new GasCoinPurchaseController{salt: _salt}(_owner, _feeManager, _metadataRouter);
    }

    function deployStablecoinPurchaseController(
        address _owner,
        address _feeManager,
        uint8 _decimals,
        string memory _currency,
        address[] memory _stablecoins,
        address _metadataRouter,
        bytes32 _salt
    ) internal returns (StablecoinPurchaseController) {
        return
        new StablecoinPurchaseController{salt: _salt}(_owner, _feeManager, _decimals, _currency, _stablecoins, _metadataRouter);
    }
}
