// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
// 0xRails
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/Permissions.sol";
import {CallPermitValidator} from "0xrails/validator/CallPermitValidator.sol";
import {BotAccount} from "0xrails/cores/account/BotAccount.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {ERC20Rails} from "0xrails/cores/ERC20/ERC20Rails.sol";
import {ERC1155Rails} from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {ERC721AccountRails} from "0xrails/cores/ERC721Account/ERC721AccountRails.sol";
// GroupOS
import {AccountGroup} from "src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "src/accountGroup/module/InitializeAccountController.sol";
import {MintCreateInitializeController} from "src/accountGroup/module/MintCreateInitializeController.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {FreeMintController} from "src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "src/membership/modules/StablecoinPurchaseController.sol";
import {MetadataRouter} from "src/metadataRouter/MetadataRouter.sol";
import {OnePerAddressGuard} from "src/membership/guards/OnePerAddressGuard.sol";
import {NFTMetadataRouterExtension} from
    "src/membership/extensions/NFTMetadataRouter/NFTMetadataRouterExtension.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {GeneralFreeMintController} from "src/token/controller/GeneralFreeMintController.sol";

/// @dev Script to deploy *all* GroupOS contracts other than the Safe and AdminGuard
/// Usage:
///   forge script script/DeployAll.s.sol:DeployAll \
///     --keystore $KS --password $PW --sender $sender \
///     --fork-url $RPC_URL --broadcast -vvvv \
///     --verify --etherscan-api-key $ETHERSCAN_API_KEY --verifier-url $ETHERSCAN_ENDPOINT
contract DeployAll is ScriptUtils {

    /*=================
        ENVIRONMENT 
    =================*/

    // The following 0xRails contracts will be deployed:
    CallPermitValidator callPermitValidator;
    BotAccount botAccountImpl;
    BotAccount botAccount;
    ERC20Rails erc20Rails;
    ERC721Rails erc721Rails;
    ERC1155Rails erc1155Rails;
    ERC721AccountRails erc721AccountRails;
    // The following AccountGroup GroupOS contracts will be deployed:
    AccountGroup accountGroupImpl;
    AccountGroup accountGroup; // proxy
    PermissionGatedInitializer permissionGatedInitializer;
    InitializeAccountController initializeAccountController;
    MintCreateInitializeController mintCreateInitializeController;
    // The following GroupOS contracts will be deployed:
    MetadataRouter metadataRouterImpl;
    MetadataRouter metadataRouter; // proxy
    TokenFactory tokenFactoryImpl;
    TokenFactory tokenFactory; // proxy
    OnePerAddressGuard onePerAddressGuard;
    NFTMetadataRouterExtension nftMetadataRouterExtension;
    PayoutAddressExtension payoutAddressExtension;
    FeeManager feeManager;
    FreeMintController erc721FreeMintController;
    GasCoinPurchaseController erc721GasCoinPurchaseController;
    StablecoinPurchaseController erc721StablecoinPurchaseController;
    GeneralFreeMintController generalFreeMintController;

    /*============
        CONFIG
    ============*/

    // `deployStablecoinPurchaseController` params configuration
    uint8 decimals = 2;
    string currency = "USD";

    address owner = ScriptUtils.stationFounderSafe;
    bytes32 salt = ScriptUtils.create2Salt;
    
    address[] turnkeys = [ScriptUtils.turnkey];

    Call3[] calls;

    function run() public {
       
        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        // 0xrails deployments
        callPermitValidator = deployCallPermitValidator(ScriptUtils.entryPointAddress, salt);
        (botAccountImpl, botAccount) = deployBotAccount(ScriptUtils.entryPointAddress, owner, turnkeys, salt);
        (erc20Rails, erc721Rails, erc1155Rails) = deployERCTokenRailsImpls(salt);
        erc721AccountRails = deployERC721AccountRails(ScriptUtils.entryPointAddress, salt);

        // accountGroup deployments
        (accountGroupImpl, accountGroup) = deployAccountGroup(salt, owner);
        permissionGatedInitializer = deployPermissionGatedInitializer(salt);
        initializeAccountController = deployInitializeAccountController(salt);
        mintCreateInitializeController = deployMintCreateInitializeController(salt);

        // groupOS deployments
        (metadataRouterImpl, metadataRouter) = deployMetadataRouter(salt, owner);
        (tokenFactoryImpl, tokenFactory) = deployTokenFactory(salt, owner, address(erc20Rails), address(erc721Rails), address(erc1155Rails));

        onePerAddressGuard = deployOnePerAddressGuard(salt);
        nftMetadataRouterExtension = deployNFTMetadataRouterExtension(salt, address(metadataRouter));
        payoutAddressExtension = deployPayoutAddressExtension(salt);

        feeManager = FeeManager(deployFeeManager(owner, salt));
        erc721FreeMintController = deployFreeMintController(owner, address(feeManager), salt);
        erc721GasCoinPurchaseController = deployGasCoinPurchaseController(owner, address(feeManager), salt);

        // using stablecoin 'environment' params above
        erc721StablecoinPurchaseController =
            deployStablecoinPurchaseController(owner, address(feeManager), decimals, currency, salt);

        generalFreeMintController = deployGeneralFreeMintController(salt);

        // After deployments, format Multicall3 calls and execute it from FounderSafe as module sender
        
        // `AccountGroup::setDefaultAccountInitializer` configuration
        bytes memory setDefaultAccountInitializer = abi.encodeWithSelector(
            AccountGroup.setDefaultAccountInitializer.selector, address(permissionGatedInitializer)
        );
        Call3 memory accountGroupSetDefaultAccountInitializerCall =
            Call3({target: address(accountGroup), allowFailure: false, callData: setDefaultAccountInitializer});
        calls.push(accountGroupSetDefaultAccountInitializerCall);

        // `AccountGroup::setDefaultAccountImplementation` configuration
        bytes memory setDefaultAccountImplementation =
            abi.encodeWithSelector(AccountGroup.setDefaultAccountImplementation.selector, address(erc721AccountRails));
        Call3 memory accountGroupSetDefaultAccountImplementationCall =
            Call3({target: address(accountGroup), allowFailure: false, callData: setDefaultAccountImplementation});
        calls.push(accountGroupSetDefaultAccountImplementationCall);

        // `AccountGroup::addPermission(INITIALIZE_ACCOUNT, mintCreateInitializeController)` configuration
        bytes memory addPermissionInitializeAccountToMintCreateInitializeController = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, address(mintCreateInitializeController)
        );
        Call3 memory addPermissionInitializeAccountToMintCreateInitializeControllerCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountToMintCreateInitializeController
        });
        calls.push(addPermissionInitializeAccountToMintCreateInitializeControllerCall);

        // `AccountGroup::addPermission(INITIALIZE_ACCOUNT, initializeAccountController)` configuration
        bytes memory addPermissionInitializeAccountToInitializeAccountController = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)
        );
        Call3 memory addPermissionInitializeAccountToInitializeAccountControllerCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountToInitializeAccountController
        });
        calls.push(addPermissionInitializeAccountToInitializeAccountControllerCall);

        // `AccountGroup::addPermission(INITIALIZE_ACCOUNT_PERMIT, turnkey)` configuration
        bytes memory addPermissionInitializeAccountPermitToTurnkey = abi.encodeWithSelector(
            IPermissions.addPermission.selector, Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey
        );
        Call3 memory addPermissionInitializeAccountPermitToTurnkeyCall = Call3({
            target: address(accountGroup),
            allowFailure: false,
            callData: addPermissionInitializeAccountPermitToTurnkey
        });
        calls.push(addPermissionInitializeAccountPermitToTurnkeyCall);

        // `MetadataRouter::setDefaultURI()` configuration
        string memory defaultURI = "https://groupos.xyz/api/v1/contractMetadata";
        bytes memory setDefaultURIData = abi.encodeWithSelector(MetadataRouter.setDefaultURI.selector, defaultURI);
        Call3 memory metadataRouterSetDefaultURICall =
            Call3({target: address(metadataRouter), allowFailure: false, callData: setDefaultURIData});
        calls.push(metadataRouterSetDefaultURICall);

        // `MetadataRouter::setRouteURI()` configuration
        string memory route = "token";
        string memory uri = "https://groupos.xyz/api/v1/nftMetadata";
        bytes memory setRouteURIData = abi.encodeWithSelector(MetadataRouter.setRouteURI.selector, route, uri);
        Call3 memory metadataRouterSetRouteURICall =
            Call3({target: address(metadataRouter), allowFailure: false, callData: setRouteURIData});
        calls.push(metadataRouterSetRouteURICall);

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        // assert accountGroup and metadataRouter calls were successful
        assert(accountGroup.getDefaultAccountInitializer() == address(permissionGatedInitializer));
        assert(accountGroup.getDefaultAccountImplementation() == address(erc721AccountRails));
        assert(accountGroup.hasPermission(Operations.INITIALIZE_ACCOUNT, address(initializeAccountController)));
        assert(accountGroup.hasPermission(Operations.INITIALIZE_ACCOUNT_PERMIT, ScriptUtils.turnkey));
        assert(erc721AccountRails.initialized() == true);
        assert(keccak256(bytes(metadataRouter.defaultURI())) == keccak256(bytes(defaultURI)));
        assert(keccak256(bytes(metadataRouter.routeURI(route))) == keccak256(bytes(uri)));

        vm.stopBroadcast();

        // 0xRails contracts
        logAddress("CallPermitValidator @", Strings.toHexString(address(callPermitValidator)));
        logAddress("BotAccountImpl @", Strings.toHexString(address(botAccountImpl)));
        logAddress("botAccount @", Strings.toHexString(address(botAccount)));
        logAddress("ERC721Rails @", Strings.toHexString(address(erc721Rails)));
        logAddress("ERC20Rails @", Strings.toHexString(address(erc20Rails)));
        logAddress("ERC1155Rails @", Strings.toHexString(address(erc1155Rails)));
        logAddress("ERC721AccountRails @", Strings.toHexString(address(erc721AccountRails)));
        // GroupOS AccountGroup contracts
        logAddress("PermissionGatedInitializer @", Strings.toHexString(address(permissionGatedInitializer)));
        logAddress("InitializeAccountController @", Strings.toHexString(address(initializeAccountController)));
        logAddress("MintCreateInitializeController @", Strings.toHexString(address(mintCreateInitializeController)));
        logAddress("AccountGroupImpl @", Strings.toHexString(address(accountGroupImpl)));
        logAddress("AccountGroup @", Strings.toHexString(address(accountGroup)));
        // GroupOS contracts
        logAddress("MetaDataRouterImpl @", Strings.toHexString(address(metadataRouterImpl)));
        logAddress("MetaDataRouterProxy @", Strings.toHexString(address(metadataRouter)));
        logAddress("TokenFactoryImpl @", Strings.toHexString(address(tokenFactoryImpl)));
        logAddress("TokenFactoryProxy @", Strings.toHexString(address(tokenFactory)));
        logAddress("OnePerAddressGuard @", Strings.toHexString(address(onePerAddressGuard)));
        logAddress("NFTMetadataRouterExtension @", Strings.toHexString(address(nftMetadataRouterExtension)));
        logAddress("PayoutAddressExtension @", Strings.toHexString(address(payoutAddressExtension)));
        logAddress("FeeManager @", Strings.toHexString(address(feeManager)));
        logAddress("ERC721FreeMintController @", Strings.toHexString(address(erc721FreeMintController)));
        logAddress("ERC721GasCoinPurchaseController @", Strings.toHexString(address(erc721GasCoinPurchaseController)));
        logAddress("ERC721StablecoinPurchaseController @", Strings.toHexString(address(erc721StablecoinPurchaseController)));
        logAddress("GeneralFreeMintController @", Strings.toHexString(address(generalFreeMintController)));
    }

    function deployCallPermitValidator(address _entryPointAddress, bytes32 _salt) internal returns (CallPermitValidator _callPermitValidator) {
        _callPermitValidator = new CallPermitValidator{salt: _salt}(_entryPointAddress);
    }
    
    function deployBotAccount(address _entryPointAddress, address _owner, address[] memory _turnkeys, bytes32 _salt) internal returns (BotAccount _botAccountImpl, BotAccount _botAccountProxy) {
        _botAccountImpl = new BotAccount{salt: _salt}(_entryPointAddress);

        _botAccountProxy = BotAccount(payable(address(new ERC1967Proxy{salt: _salt}(address(_botAccountImpl), ''))));
        _botAccountProxy.initialize(_owner, address(callPermitValidator), _turnkeys);
    
        // the two previous calls are external so they are broadcast as separate txs; thus check state externally
        if (!_botAccountProxy.initialized()) revert Create2Failure();
    }

    function deployERCTokenRailsImpls(bytes32 _salt) internal returns (ERC20Rails _erc20RailsImpl, ERC721Rails _erc721RailsImpl, ERC1155Rails _erc1155RailsImpl) {
        _erc20RailsImpl = new ERC20Rails{salt: _salt}();
        _erc721RailsImpl = new ERC721Rails{salt: _salt}();
        _erc1155RailsImpl = new ERC1155Rails{salt: _salt}();
    }

    function deployERC721AccountRails(address _entryPointAddress, bytes32 _salt) internal returns (ERC721AccountRails _erc721AccountRails) {
        _erc721AccountRails = new ERC721AccountRails{salt: _salt}(_entryPointAddress);
    }

    function deployAccountGroup(bytes32 _salt, address _owner)
        internal
        returns (AccountGroup _impl, AccountGroup _proxy)
    {
        _impl = new AccountGroup{salt: _salt}();
        bytes memory accountGroupInitData = abi.encodeWithSelector(AccountGroup.initialize.selector, _owner);
        _proxy = AccountGroup(address(new ERC1967Proxy{salt: _salt}(address(_impl), accountGroupInitData)));
    }

    function deployPermissionGatedInitializer(bytes32 _salt) internal returns (PermissionGatedInitializer _permissionGatedInitializer) {
        _permissionGatedInitializer = new PermissionGatedInitializer{salt: _salt}();
    }

    function deployInitializeAccountController(bytes32 _salt) internal returns (InitializeAccountController _initializeAccountController) {
        _initializeAccountController = new InitializeAccountController{salt: _salt}();
    }

    function deployMintCreateInitializeController(bytes32 _salt) internal returns (MintCreateInitializeController _mintCreateInitializeController) {
        _mintCreateInitializeController = new MintCreateInitializeController{salt: _salt}();
    }

    function deployMetadataRouter(bytes32 _salt, address _owner)
        internal
        returns (MetadataRouter _impl, MetadataRouter _proxy)
    {
        _impl = new MetadataRouter{salt: _salt}();
        bytes memory metadataRouterInitData = abi.encodeWithSelector(MetadataRouter.initialize.selector, _owner);
        _proxy = MetadataRouter(address(new ERC1967Proxy{salt: _salt}(address(_impl), metadataRouterInitData)));
    }

    function deployTokenFactory(bytes32 _salt, address _owner, address _erc20Rails, address _erc721Rails, address _erc1155Rails)
        internal
        returns (TokenFactory _impl, TokenFactory _proxy)
    {
        _impl = new TokenFactory{salt: _salt}();
        bytes memory tokenFactoryInitData = abi.encodeWithSelector(TokenFactory.initialize.selector, _owner, _erc20Rails, _erc721Rails, _erc1155Rails);
        _proxy = TokenFactory(address(new ERC1967Proxy{salt: _salt}(address(_impl), tokenFactoryInitData)));
    }

    function deployOnePerAddressGuard(bytes32 _salt) internal returns (OnePerAddressGuard) {
        return new OnePerAddressGuard{salt: _salt}();
    }

    function deployNFTMetadataRouterExtension(bytes32 _salt, address _metadataRouter)
        internal
        returns (NFTMetadataRouterExtension)
    {
        return new NFTMetadataRouterExtension{salt: _salt}(_metadataRouter);
    }

    function deployPayoutAddressExtension(bytes32 _salt) internal returns (PayoutAddressExtension) {
        return new PayoutAddressExtension{salt: _salt}();
    }

    function deployFeeManager(address _owner, bytes32 _salt) internal returns (FeeManager) {
        uint120 _ethBaseFee = 1e15; // 0.001 ETH
        uint120 _defaultBaseFee = 0;
        uint120 _defaultVariableFee = 500; // 5%

        return
            new FeeManager{salt: _salt}(_owner, _defaultBaseFee, _defaultVariableFee, _ethBaseFee, _defaultVariableFee);
    }

    function deployFreeMintController(address _owner, address _feeManager, bytes32 _salt)
        internal
        returns (FreeMintController)
    {
        return new FreeMintController{salt: _salt}(_owner, _feeManager);
    }

    function deployGasCoinPurchaseController(address _owner, address _feeManager, bytes32 _salt)
        internal
        returns (GasCoinPurchaseController)
    {
        return new GasCoinPurchaseController{salt: _salt}(_owner, _feeManager);
    }

    function deployStablecoinPurchaseController(
        address _owner,
        address _feeManager,
        uint8 _decimals,
        string memory _currency,
        bytes32 _salt
    ) internal returns (StablecoinPurchaseController) {
        return new StablecoinPurchaseController{salt: _salt}(_owner, _feeManager, _decimals, _currency);
    }

    function deployGeneralFreeMintController(bytes32 _salt) internal returns (GeneralFreeMintController _generalFreeMintController) {
        _generalFreeMintController = new GeneralFreeMintController{salt: _salt}();
    }
}
