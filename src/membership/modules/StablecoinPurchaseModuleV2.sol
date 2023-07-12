// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFee} from "src/lib/module/ModuleFee.sol";
// use SafeERC20: https://soliditydeveloper.com/safe-erc20
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20 as IERC20Base} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @notice Mint membership tokens when users pay a fixed amount of a stablecoin.
/// @author symmetry (@symmtry69), frog (@0xmcg)
/// @notice Mint membership tokens when users pay a fixed amount of a stablecoin
/// @dev Storage is designed to minimize costs for accepting multiple stablecoins as
/// payment by packing all data into 1 slot. Updating the price for N stablecoins has
/// constant G(1) gas complexity. Additionally, it is guaranteed that all stablecoins
/// will use the same price value and can never get out of sync. Deploy one instance
/// of this module per currency, per chain (e.g. USD, EUR, BTC).
contract StablecoinPurchaseModuleV2 is ModuleFee, ModuleSetup, ModuleGrant {
    using SafeERC20 for IERC20;

    struct Parameters {
        uint128 price;
        bytes16 enabledCoins;
    }

    /*=============
        STORAGE
    =============*/

    // decimals of percision for currency type
    uint8 public immutable decimals;
    // currency type for this particular contract. (USD, EUR, etc.)
    string public currency;
    // how many keys currently exist in map
    uint8 public keyCounter;
    // stablecoin address -> key in bitmap
    mapping(address => uint8) internal _keyOf;
    // bitmap key -> stablecoin address
    mapping(uint8 => address) internal _stablecoinOf;
    // collection => mint parameters
    mapping(address => Parameters) internal _parameters;
    // TODO: pack collection config storage to one slot
    mapping(address => bool) internal _repealGrants;

    /*============
        EVENTS
    ============*/

    event Register(address indexed stablecoin, uint8 indexed key);
    event SetUp(address indexed collection, uint128 price, bytes16 enabledCoins, bool indexed enforceGrants);
    event Purchase(
        address indexed collection,
        address indexed recipient,
        address indexed paymentCoin,
        uint256 unitPrice,
        uint256 unitFee,
        uint256 units
    );

    /*============
        CONFIG
    ============*/

    constructor(address _owner, uint256 _fee, uint8 _decimals, string memory _currency, address[] memory stablecoins)
        ModuleFee(_owner, _fee)
    {
        decimals = _decimals;
        currency = _currency;
        for (uint256 i; i < stablecoins.length; i++) {
            _register(stablecoins[i]);
        }
    }

    function register(address stablecoin) external onlyOwner returns (uint8 newKey) {
        return _register(stablecoin);
    }

    function _register(address stablecoin) internal returns (uint8 newKey) {
        require(_keyOf[stablecoin] == 0, "STABLECOIN_ALREADY_REGISTERED");
        newKey = ++keyCounter;
        _keyOf[stablecoin] = newKey;
        _stablecoinOf[newKey] = stablecoin;
        emit Register(stablecoin, newKey);
    }

    function keyOf(address stablecoin) public view returns (uint8 key) {
        key = _keyOf[stablecoin];
        require(key > 0, "STABLECOIN_NOT_REGISTERED");
    }

    function stablecoinOf(uint8 key) public view returns (address stablecoin) {
        stablecoin = _stablecoinOf[key];
        require(stablecoin != address(0), "KEY_NOT_REGISTERED");
    }

    /*============
        SET UP
    ============*/

    function setUp(address collection, uint128 price, bytes16 enabledCoins, bool enforceGrants)
        external
        canSetUp(collection)
    {
        require(price > 0, "ZERO_PRICE");
        _parameters[collection] = Parameters(price, enabledCoins);
        if (_repealGrants[collection] != !enforceGrants) {
            _repealGrants[collection] = !enforceGrants;
        }
        emit SetUp(collection, price, enabledCoins, enforceGrants);
    }

    /*===================
        ENABLED COINS
    ===================*/

    function enabledCoinsValueOf(address collection) external view returns (bytes16) {
        return _parameters[collection].enabledCoins;
    }

    function enabledCoinsOf(address collection) external view returns (address[] memory stablecoins) {
        // cache state to save reads
        uint256 len = keyCounter;
        bytes16 enabledCoins = _parameters[collection].enabledCoins;
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

    function stablecoinEnabled(address collection, address stablecoin) external view returns (bool) {
        return _stablecoinEnabled(_parameters[collection].enabledCoins, stablecoin);
    }

    function _stablecoinEnabled(bytes16 enabledCoins, address stablecoin) internal view returns (bool) {
        return (enabledCoins & _keyBitOf(stablecoin)) > 0;
    }

    function enabledCoinsValue(address[] memory stablecoins) external view returns (bytes16 value) {
        for (uint256 i; i < stablecoins.length; i++) {
            value |= _keyBitOf(stablecoins[i]);
        }
    }

    function _keyBitOf(address stablecoin) internal view returns (bytes16) {
        return bytes16(uint128(1 << keyOf(stablecoin)));
    }

    /*====================
        PURCHASE PRICE
    ====================*/

    function priceOf(address collection) external view returns (uint128 price) {
        price = _parameters[collection].price;
        require(price > 0, "NO_PRICE");
    }

    function mintPriceToStablecoinAmount(uint256 price, address stablecoin) public view returns (uint256) {
        uint256 stablecoinDecimals = IERC20(stablecoin).decimals();
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

    /*==========
        MINT
    ==========*/

    function mint(address collection, address paymentCoin) external payable returns (uint256 tokenId) {
        (tokenId,) = _batchMint(collection, paymentCoin, msg.sender, 1);
    }

    function mintTo(address collection, address paymentCoin, address recipient)
        external
        payable
        returns (uint256 tokenId)
    {
        (tokenId,) = _batchMint(collection, paymentCoin, recipient, 1);
    }

    /// @notice returned tokenId range is inclusive
    function batchMint(address collection, address paymentCoin, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, paymentCoin, msg.sender, amount);
    }

    /// @notice returned tokenId range is inclusive
    function batchMintTo(address collection, address paymentCoin, address recipient, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, paymentCoin, recipient, amount);
    }

    /// @notice returned tokenId range is inclusive
    function _batchMint(address collection, address paymentCoin, address recipient, uint256 amount)
        internal
        enableGrants(abi.encodePacked(collection))
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        require(amount > 0, "ZERO_AMOUNT");
        Parameters memory params = _parameters[collection];
        require(_stablecoinEnabled(params.enabledCoins, paymentCoin), "STABLECOIN_NOT_ENABLED");
        uint256 totalCost = mintPriceToStablecoinAmount(params.price * amount, paymentCoin);

        // take fee
        uint256 paidFee = _registerFeeBatch(amount);

        // transfer payment
        address paymentCollector = IMembership(collection).paymentCollector();
        // prevent accidentally unset payment collector
        require(paymentCollector != address(0), "MISSING_PAYMENT_COLLECTOR");
        // use SafeERC20 for covering USDT no-return and other transfer issues
        IERC20(paymentCoin).safeTransferFrom(msg.sender, paymentCollector, totalCost);

        for (uint256 i; i < amount; i++) {
            // mint token
            (uint256 tokenId) = IMembership(collection).mintTo(recipient);
            // prevent unsuccessful mint
            require(tokenId > 0, "MINT_FAILED");
            // set startTokenId on first mint
            if (startTokenId == 0) {
                startTokenId = tokenId;
            }
        }

        emit Purchase(collection, recipient, paymentCoin, params.price, paidFee / amount, amount);

        return (startTokenId, startTokenId + amount - 1); // purely inclusive set
    }

    /*============
        GRANTS
    ============*/

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

// need base IERC20 for SafeERC20 to wrap
// need IERC20Metadata for `decimals()`
interface IERC20 is IERC20Base, IERC20Metadata {}
