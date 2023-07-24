// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFeeV2} from "src/lib/module/ModuleFeeV2.sol";
import {StablecoinRegistry} from "src/lib/module/storage/StablecoinRegistry.sol";
// use SafeERC20: https://soliditydeveloper.com/safe-erc20
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Station Network PurchaseModule Contract
/// @author 👦🏻👦🏻.eth

/// @dev This contract handles payment configurations for all Membership collections in both ETH and Stablecoins, including free mints
/// The goal is to abstract all client-facing payment logic so this module can be used as a strikingly simple plugin for clients and developers to customize

/// TODO Should be converted to a UUPS proxy for upgradeability once approved for production

contract PurchaseModule is ModuleGrant, ModuleFeeV2, ModuleSetup, StablecoinRegistry {
    using SafeERC20 for IERC20Metadata;

    /// @dev Struct of collection price data, including options for both ETH and stablecoins
    /// @param freeMint A quasi-Boolean value indicating whether the collection is a free mint. 1 represents `false` and 2 represents `true`
    /// 8 byte unsigned integers 1 || 2 are utilized instead of 0 || 1 for two reasons: 
    /// 1. Provide a quantifiable, nonzero indication that a collection exists and has been registered with Station by an authorized Module
    /// 2. Save gas on initialization costs when setting a cold, ie 0, storage slot
    /// @param ethPrice The price in Wei set for a collection's mint. 
    /// Max value of uint128 (~3.4e38) is several orders of magnitude larger than the current total supply of Ethereum (1.2e26 wei) so it suffices for ETH price
    /// @param stablecoinPrice The price in stablecoins set for a collection's mint
    /// @param enabledCoins A bitmap of single byte keys that correspond to supported stablecoins, managed by the StablecoinRegistry contract
    struct CollectionConfig {
        uint8 freeMint;
        uint128 ethPrice;
        uint128 stablecoinPrice;
        bytes16 enabledCoins;
    }

    /*============
        EVENTS
    ============*/

    /// @notice Uses preexisting events from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility
    /// @notice TODO: go over requirements for backwards compatibility of event emissions to offchain API:
    /// Should there be 3 events: FreePurchase, ETHPurchase, StablecoinPurchase? Or is offchain filtering by address(0) & unitPrice == 0 sufficient
    event Register(address indexed stablecoin, uint8 indexed key);
    event SetUp(
        address indexed collection, 
        uint8 freeMint,
        uint128 ethPrice, 
        uint128 stablecoinPrice, 
        address[] enabledCoins, 
        bool indexed enforceGrants
    );
    event Mint(address indexed collection, address indexed recipient, uint256 fee);
    
    /// @notice TODO: discuss refactoring of `unitFee` member in Purchase event to accommodate base / variable fees
    event Purchase(
        address indexed collection,
        address indexed recipient,
        address indexed paymentCoin,
        uint256 unitPrice,
        uint256 unitFee,
        uint256 units
    );

    /*=============
        STORAGE
    =============*/

    /// @dev Decimals of precision for most common stablecoins (USDC + USDT), stored in runtime bytecode to save gas
    uint8 public immutable decimals;
    /// @dev The total number of keys currently in bitmap, initialized to the number of default addresses in StablecoinRegistry
    /// @notice This counter may eventually need to exceed 255 stablecoin address keys (and bytes16 enabledCoins map) as Station gains adoption
    uint8 public keyCounter;

    /// @dev Mapping of stablecoin address => associated key in bitmap
    mapping(address => uint8) internal _keyOf;

    /// @dev Mapping of bitmap key => stablecoin address
    mapping(uint8 => address) internal _stablecoinOf;

    /// @dev Mapping of each collection => mint purchase configuration
    mapping(address => CollectionConfig) internal _collectionConfig;

    /// @dev Mapping to show if a collection prevents or allows minting via signature grants, ie collection address => repealGrants
    /// @notice todo Can improve gas efficiency here by using `uint 1 || 2` as opposed to `bool 0 || 1` due to repeated cold slot (ie 0) initialization costs
    mapping(address => bool) internal _repealGrants;

    /*============
        CONFIG
    ============*/
    /// @notice Uses preexisting config and setup logic from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility

    /// @dev The default stablecoin addresses are registered in _keyOF and _stablecoinOf storage mappings despite not being read outside of view functions
    /// This is purely for consistency and cleanliness of storage layout, at small increased cost at deployment time
    /// @param _owner The owner of the ModuleFeeV2, an address managed by Station Network
    /// @param _feeManagerProxy The FeeManager's proxy address
    /// @param _decimals The decimals value for supported stablecoin payments, using the most commonly expected value to maximize gas efficiency
    /// @param stablecoins Additional stablecoin contract addresses beyond the most common defaults which are handled by the StablecoinRegistry contract
    constructor(address _owner, address _feeManagerProxy, uint8 _decimals, address[] memory stablecoins)
        ModuleFeeV2(_owner, _feeManagerProxy)
    {
        decimals = _decimals;
        // get default stablecoins for this chainId to be registered
        address[] memory defaultCoins = _getDefaultAddresses();
        // overflow is impossible due to constrained bitmap member length, nice to save a bit of gas
        unchecked {
            for (uint256 i; i < defaultCoins.length; ++i) {
                _register(defaultCoins[i]);
            }
            for (uint256 j; j < stablecoins.length; ++j) {
                _register(stablecoins[j]);
            }
        }
        // set keyCounter to length of defaults + additional stablecoins array length
        keyCounter = uint8(defaultCoins.length) + uint8(stablecoins.length);
    }

    /// @dev Function to set up and configure a new collection's purchase prices and payment options
    /// @param collection The new collection to configure
    /// @param ethPrice The price in ETH for this collection's mints
    /// @param stablecoinPrice The price in a stablecoin currency for this collection's mints
    /// @param enabledCoins The stablecoin addresses to be supported for this collection's mints
    /// @param enforceGrants A boolean to represent whether this collection will repeal or support grant functionality 
    function setUp(
        address collection, 
        uint8 freeMint, 
        uint128 ethPrice, 
        uint128 stablecoinPrice, 
        address[] memory enabledCoins, 
        bool enforceGrants
    )
        external
        canSetUp(collection)
    {
        // enforce quasi-boolean freeMint input and set a nonzero value to freeMint to show collection is registered
        require(freeMint == 1 || freeMint == 2, "INVALID_FREEMINT_BOOLEAN");
        // enforce correct input data by reverting tautologies
        if (freeMint == 2) require(ethPrice == 0 && stablecoinPrice == 0 && enabledCoins.length == 0);

        _collectionConfig[collection] = CollectionConfig(freeMint, ethPrice, stablecoinPrice, _enabledCoinsValue(enabledCoins));
        if (_repealGrants[collection] != !enforceGrants) {
            _repealGrants[collection] = !enforceGrants;
        }
        emit SetUp(collection, freeMint, ethPrice, stablecoinPrice, enabledCoins, enforceGrants);
    }

    /// @dev Function to register new stablecoins in addition to the defaults provided by StablecoinRegistry, when requested by clients
    /// @param stablecoin The stablecoin token contract to register in the bitmap
    function register(address stablecoin) external onlyOwner returns (uint8 newKey) {
        return _register(stablecoin);
    }

    function _register(address stablecoin) internal returns (uint8 newKey) {
        require(_keyOf[stablecoin] == 0, "STABLECOIN_ALREADY_REGISTERED");
        newKey = ++keyCounter; // increment then set, first key starts at 1 to leave 0 empty for null value
        _keyOf[stablecoin] = newKey;
        _stablecoinOf[newKey] = stablecoin;
        emit Register(stablecoin, newKey);
    }

    /*==========
        MINT
    ==========*/
    /// @notice Uses preexisting mint logic from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility

    /// @dev Function to mint a single collection token to the caller, in this case a user
    /// @param collection The token collection to mint from
    /// @param paymentCoin The ERC20 contract address of the coin being used to pay
    function mint(address collection, address paymentCoin) external payable returns (uint256 tokenId) {
        (,tokenId) = _batchMint(collection, paymentCoin, msg.sender, 1);
    }

    //todo
    //function mintTo

    /// @dev Function mint collection tokens in batches to a specified recipient
    /// @dev The check for collectionConfig.freeMint != 0 ensures that a collection has been registered and set up with Station Network
    /// @param collection The token collection to mint from
    /// @param paymentCoin The stablecoin address being used for payment
    /// @param recipient The recipient of successfully minted tokens
    /// @param amount The amount of tokens to mint  
    /// @notice returned tokenId range is inclusive
    function _batchMint(
        address collection, 
        address paymentCoin, 
        address recipient, 
        uint256 amount
    ) internal enableGrants(abi.encode(collection))
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        require(amount > 0, "ZERO_AMOUNT");
        CollectionConfig memory collectionConfig = _collectionConfig[collection];
        require(collectionConfig.freeMint != 0, "COLLECTION_NOT_REGISTERED");

        uint256 paidFee;
        // need only check free mint boolean as setUp() enforces collection configuration prices == 0
        if (collectionConfig.freeMint == 2) {
            // get and then registers fees for free mint of single token, reverting on invalid fee
            paidFee = _registerFee(
                collection,
                paymentCoin,
                recipient,
                0
            );

            // free mint context only supports single token mints
            tokenId = IMembership(collection).mintTo(recipient);
            emit Mint(collection, recipient, paidFee);
            return (tokenId - 1, tokenId); // startTokenId discarded for single mints
        } else {
            uint256 preFeeTotal;
            // external call safe here since collection's registration was verified via config's freeMint
            address paymentCollector = Membership(collection).paymentCollector();
            // prevent accidentally unset payment collector
            require(paymentCollector != address(0), "MISSING_PAYMENT_COLLECTOR");

            if (paymentCoin == address(0x0)) {
                // handle ETH context totals
                preFeeTotal = collectionConfig.ethPrice * amount;

                // get total invoice incl fees and register to storage
                paidFee = _registerFeeBatch(
                    collection, 
                    paymentCoin, 
                    recipient, 
                    amount, 
                    collectionConfig.ethPrice
                );

                // send payment
                (bool success,) = paymentCollector.call{ value: preFeeTotal }("");
                require(success, "PAYMENT_FAIL");

                // perform batch mint
                for (uint256 i; i < amount; ++i) {
                    // mint token
                    uint256 tokenId = IMembership(collection).mintTo(recipient);
                    // prevent unsuccessful mint
                    require(tokenId > 0, "MINT_FAILED");
                    // set startTokenId on first mint
                    if (startTokenId == 0) {
                        startTokenId = tokenId;
                    }
                }

                /// @notice `unitFee` value set as placeholder of baseFee + variableFee (ie: total invoice - preFeeTotal)
                emit Purchase(collection, recipient, paymentCoin, collectionConfig.ethPrice, paidFee - preFeeTotal, amount);

                return (startTokenId, startTokenId + amount - 1); // purely inclusive set

            } else {
                // handle stablecoin context totals
                require(_stablecoinEnabled(collectionConfig.enabledCoins, paymentCoin), "STABLECOIN_NOT_ENABLED");
                // format decimals for preFeeTotal
                preFeeTotal = mintPriceToStablecoinAmount(collectionConfig.stablecoinPrice * amount, paymentCoin);

                // get total invoice incl fees and collect fee 
                paidFee = _registerFeeBatch(
                    collection, 
                    paymentCoin, 
                    recipient, 
                    amount, 
                    collectionConfig.stablecoinPrice
                );

                // approval must have been made prior to top-level mint call
                try {
                    IERC20Metadata(collection).safeTransferFrom(msg.sender, address(this), paidFee - preFeeTotal);
                } catch {
                    revert FeeCollectFailed()
                }

                // transfer remaining payment to collector using SafeERC20 for covering USDT no-return and other transfer issues
                IERC20Metadata(paymentCoin).safeTransferFrom(msg.sender, paymentCollector, preFeeTotal);

                // perform batch mint
                for (uint256 i; i < amount; i++) {
                    // mint token
                    uint256 tokenId = IMembership(collection).mintTo(recipient);
                    // prevent unsuccessful mint
                    require(tokenId > 0, "MINT_FAILED");
                    // set startTokenId on first mint
                    if (startTokenId == 0) {
                        startTokenId = tokenId;
                    }
                }

                /// @notice `unitFee` value set as placeholder of baseFee + variableFee (ie: total invoice - preFeeTotal)
                emit Purchase(collection, recipient, paymentCoin, collectionConfig.stablecoinPrice, paidFee - preFeeTotal, amount);

                return (startTokenId, startTokenId + amount - 1); // purely inclusive set
            }
        }
    }

    /*==========
        VIEWS
    ==========*/
    /// @notice Uses preexisting view functions from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility
    
    /// @dev Function to get the configuration of a collection, incl free mint boolean, ETH price, stablecoin price, and enabled stablecoins
    /// @param collection The collection to query against _collectionConfig storage mapping
    /// @notice This function is one of a couple that could not be kept backwards compatible as this monomodule handles more than once kind of price
    function priceOf(address collection) external view returns (CollectionConfig memory prices) {
        prices = _collectionConfig[collection];
    }

    /// @dev Function to check the bitmap key for a stablecoin
    /// @param stablecoin The stablecoin address to query against the _keyOf storage mapping
    function keyOf(address stablecoin) public view returns (uint8 key) {
        key = _keyOf[stablecoin];
        require(key > 0, "STABLECOIN_NOT_REGISTERED");
    }

    /// @dev Function to get the stablecoin contract address for a specific bitmap key
    /// @param key The bitmap key to query against the _stablecoinOf storage mapping
    function stablecoinOf(uint8 key) public view returns (address stablecoin) {
        stablecoin = _stablecoinOf[key];
        require(stablecoin != address(0), "KEY_NOT_REGISTERED");
    }

    /// @dev Function to get the entire set of stablecoins supported by this module
    function stablecoinOptions() public view returns (address[] memory stablecoins) {
        uint256 len = keyCounter;
        stablecoins = new address[](len);
        for (uint8 i; i < len; i++) {
            stablecoins[i] = _stablecoinOf[i + 1]; // key index starts at 1
        }
    }

    /// @dev Function to get the enabled stablecoins of a collection
    /// @param collection The collection for which stablecoins are enabled
    function enabledCoinsOf(address collection) external view returns (address[] memory stablecoins) {
        
        // cache state to save reads
        uint256 len = keyCounter;
        bytes16 enabledCoins = _collectionConfig[collection].enabledCoins;
        // construct array of max length, front-packed
        address[] memory fullArray = new address[](len);
        uint8 enabledCount;
        for (uint256 i; i < len; i++) {
            uint8 key = uint8(i + 1);
            if (enabledCoins & bytes16(uint128(1 << key)) > 0) {
                fullArray[enabledCount] = _stablecoinOf[key];
                enabledCount++;
            }
        }
        // trim down array size using enabledCount
        stablecoins = new address[](enabledCount);
        for (uint256 i; i < enabledCount; i++) {
            stablecoins[i] = fullArray[i];
        }
    }

    /// @dev Function to check if a specific stablecoin is enabled for a collection. Reverts for unregistered stablecoins.
    /// @param collection The collection to check against _collectionConfig storage mapping
    /// @param stablecoin The stablecoin being queried against the provided collection address
    function stablecoinEnabled(address collection, address stablecoin) external view returns (bool) {
        return _stablecoinEnabled(_collectionConfig[collection].enabledCoins, stablecoin);
    }

    function _stablecoinEnabled(bytes16 enabledCoins, address stablecoin) internal view returns (bool) {
        return (enabledCoins & _keyBitOf(stablecoin)) > 0;
    }

    /// @dev Internal function to process an array of stablecoin addresses into a packed 16 byte bitmap of their corresponding keys
    /// @param stablecoins The stablecoin addresses to process
    function _enabledCoinsValue(address[] memory stablecoins) internal view returns (bytes16 value) {
        // overflow impossible due to bitmap constraints
        unchecked {
            for (uint256 i; i < stablecoins.length; ++i) {
                value |= _keyBitOf(stablecoins[i]);
            }
        }
    }

    function _keyBitOf(address stablecoin) internal view returns (bytes16) {
        return bytes16(uint128(1 << keyOf(stablecoin)));
    }

    /// @dev Function to handle decimal precision variation between stablecoin implementations
    /// @param price The desired stablecoin price to be checked against ERC20 decimals() and formatted if needed
    /// @param stablecoin The stablecoin implementation to which to conform
    function mintPriceToStablecoinAmount(uint256 price, address stablecoin) public view returns (uint256) {
        uint256 stablecoinDecimals = IERC20Metadata(stablecoin).decimals();
        // If most common stables (USDC || USDT) use price, else accommodate decimals
        if (stablecoinDecimals == decimals) {
            return price;
        } else if (stablecoinDecimals > decimals) {
            // pad zeros to input amount
            return price * 10 ** (stablecoinDecimals - decimals);
        } else {
            // reduce price precision
            uint256 precisionLoss = 10 ** (decimals - stablecoinDecimals);
            uint256 trimmedPrice = price / precisionLoss;
            if (price % precisionLoss > 0) {
                // if remainder, round up as seller protection
                return trimmedPrice + 1;
            } else {
                // no remainder value lost, return trimmed price as is
                return trimmedPrice;
            }
        }
    }


    /*============
        GRANTS
    ============*/
    
    /// @notice Grant logic from both StablecoinPurchaseModuleV2 and EthPurchaseModuleV2, consolidated into this single contract to reduce redundance
    function validateGrantSigner(bool grantInProgress, address signer, bytes memory callContext)
        public
        view
        override
        returns (bool)
    {
        address collection = abi.decode(callContext, (address));
        return (grantInProgress && Permissions(collection).hasPermission(signer, Permissions.Operation.GRANT))
            || (!grantsEnforced(collection));
    }

    function grantsEnforced(address collection) public view returns (bool) {
        return !_repealGrants[collection];
    }
}