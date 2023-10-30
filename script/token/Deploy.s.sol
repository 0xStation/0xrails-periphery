// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
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
        address[] memory stablecoins = new address[](0); // do NOT use, will make multichain addresses incompatible

        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        address owner = ScriptUtils.stationFounderSafe;

        bytes32 salt = ScriptUtils.create2Salt;
        string memory saltString = Strings.toHexString(uint256(salt), 32);
        
        // begin deployments
        (metadataRouterImpl, metadataRouter) = deployMetadataRouter(salt, owner);
        (tokenFactoryImpl, tokenFactory) = deployTokenFactory(salt, owner);

        onePerAddressGuard = deployOnePerAddressGuard(address(metadataRouter), salt);
        nftMetadataRouterExtension = deployNFTMetadataRouterExtension(address(metadataRouter), salt);
        payoutAddressExtension = deployPayoutAddressExtension(address(metadataRouter), salt);

        feeManager = FeeManager(deployFeeManager(owner, salt));
        freeMintModule = deployFreeMintController(owner, address(feeManager), address(metadataRouter), salt);
        gasCoinPurchaseController =
            deployGasCoinPurchaseController(owner, address(feeManager), address(metadataRouter), salt);

        // using stablecoin 'environment' params above
        stablecoinPurchaseController = deployStablecoinPurchaseController(
            owner, address(feeManager), decimals, currency, stablecoins, address(metadataRouter), salt
        );

        // After deployments, format Multicall3 calls and execute it from FounderSafe as module sender
        // `MetadataRouter::setDefaultURI()` configuration
        string memory defaultURI = "https://groupos.xyz/api/v1/contractMetadata";
        bytes memory setDefaultURIData = abi.encodeWithSelector(MetadataRouter.setDefaultURI.selector, defaultURI);
        Call3 memory metadataRouterSetDefaultURICall =
            Call3({target: address(metadataRouter), allowFailure: false, callData: setDefaultURIData});

        // `MetadataRouter::setRouteURI()` configuration
        string memory route = "token";
        string memory uri = "https://groupos.xyz/api/v1/nftMetadata";
        bytes memory setRouteURIData = abi.encodeWithSelector(MetadataRouter.setRouteURI.selector, route, uri);
        Call3 memory metadataRouterSetRouteURICall =
            Call3({target: address(metadataRouter), allowFailure: false, callData: setRouteURIData});

        Call3[] memory calls = new Call3[](2);
        calls[0] = metadataRouterSetDefaultURICall;
        calls[1] = metadataRouterSetRouteURICall;
        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        // assert metadataRouter calls were successful
        assert(keccak256(bytes(metadataRouter.defaultURI())) == keccak256(bytes(defaultURI)));
        assert(keccak256(bytes(metadataRouter.routeURI(route))) == keccak256(bytes(uri)));

        // missing: ExtensionBeacon

        vm.stopBroadcast();

        logAddress("MetaDataRouterImpl @", Strings.toHexString(address(metadataRouterImpl)));
        logAddress("MetaDataRouterProxy @", Strings.toHexString(address(metadataRouter)));
        logAddress("TokenFactoryImpl @", Strings.toHexString(address(tokenFactoryImpl)));
        logAddress("TokenFactoryProxy @", Strings.toHexString(address(tokenFactory)));
        logAddress("OnePerAddressGuard @", Strings.toHexString(address(onePerAddressGuard)));
        logAddress("NFTMetadataRouterExtension @", Strings.toHexString(address(nftMetadataRouterExtension)));
        logAddress("PayoutAddressExtension @", Strings.toHexString(address(payoutAddressExtension)));
        logAddress("FeeManager @", Strings.toHexString(address(feeManager)));
        logAddress("FreeMintController @", Strings.toHexString(address(freeMintModule)));
        logAddress("GasCoinPurchaseController @", Strings.toHexString(address(gasCoinPurchaseController)));
        logAddress("StablecoinPurchaseController @", Strings.toHexString(address(stablecoinPurchaseController)));
    }

    function deployMetadataRouter(bytes32 _salt, address _owner)
        internal
        returns (MetadataRouter _impl, MetadataRouter _proxy)
    {
        _impl = new MetadataRouter{salt: _salt}();
        bytes memory metadataRouterInitData = abi.encodeWithSelector(MetadataRouter.initialize.selector, _owner);
        _proxy = MetadataRouter(address(new ERC1967Proxy{salt: _salt}(address(_impl), metadataRouterInitData)));
    }

    function deployTokenFactory(bytes32 _salt, address _owner)
        internal
        returns (TokenFactory _impl, TokenFactory _proxy)
    {
        _impl = new TokenFactory{salt: _salt}();
        bytes memory tokenFactoryInitData = abi.encodeWithSelector(TokenFactory.initialize.selector, _owner);
        _proxy = TokenFactory(address(new ERC1967Proxy{salt: _salt}(address(_impl), tokenFactoryInitData)));
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

    function deployGasCoinPurchaseController(
        address _owner,
        address _feeManager,
        address _metadataRouter,
        bytes32 _salt
    ) internal returns (GasCoinPurchaseController) {
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
