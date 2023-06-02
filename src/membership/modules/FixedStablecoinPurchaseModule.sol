// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {FeeModule} from "src/lib/module/FeeModule.sol";
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ReentrancyGuard} from "solmate/src/utils/ReentrancyGuard.sol";
// use SafeERC20: https://soliditydeveloper.com/safe-erc20
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20 as IERC20Base} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract FixedStablecoinPurchaseModule is FeeModule, ModuleSetup, ReentrancyGuard {
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
    // collection => mint parameters
    mapping(address => Parameters) internal _parameters;

    /*============
        EVENTS
    ============*/

    event Register(address indexed stablecoin, uint8 indexed key);
    event SetUp(address indexed collection, uint128 price, bytes16 enabledCoins);
    event Purchase(
        address indexed collection,
        address indexed recipient,
        address indexed paymentCoin,
        uint256 unitPrice,
        uint256 unitFee,
        uint256 amountUnits
    );

    /*============
        CONFIG
    ============*/

    constructor(address _owner, uint256 _fee, uint8 _decimals, string memory _currency) FeeModule(_owner, _fee) {
        decimals = _decimals;
        currency = _currency;
    }

    function register(address stablecoin) external onlyOwner returns (uint8 newKey) {
        require(_keyOf[stablecoin] == 0, "STABLECOIN_ALREADY_REGISTERED");
        newKey = ++keyCounter;
        _keyOf[stablecoin] = newKey;
        emit Register(stablecoin, newKey);
    }

    function keyOf(address token) public view returns (uint8 key) {
        key = _keyOf[token];
        require(key > 0, "STABLECOIN_NOT_SUPPORTED");
    }

    /*============
        SET UP
    ============*/

    function setUp(address collection, uint128 price, bytes16 enabledCoins) external {
        _canSetUp(collection, msg.sender); // checks UPGRADE permission
        _setUp(collection, price, enabledCoins);
    }

    function setUp(uint128 price, bytes16 enabledCoins) external {
        _setUp(msg.sender, price, enabledCoins);
    }

    function _setUp(address collection, uint128 price, bytes16 enabledCoins) internal {
        require(price > 0, "ZERO_PRICE");
        _parameters[collection] = Parameters(price, enabledCoins);
        emit SetUp(collection, price, enabledCoins);
    }

    /*===================
        ENABLED COINS
    ===================*/

    function enabledCoinsOf(address collection) external view returns (bytes16) {
        return _parameters[collection].enabledCoins;
    }

    function stablecoinEnabled(address collection, address stablecoin) external view returns (bool) {
        return _stablecoinEnabled(_parameters[collection].enabledCoins, stablecoin);
    }

    function _stablecoinEnabled(bytes32 enabledCoins, address stablecoin) internal view returns (bool) {
        return (enabledCoins & _keyBitOf(stablecoin)) != 0;
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

    function batchMint(address collection, address paymentCoin, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, paymentCoin, msg.sender, amount);
    }

    function batchMintTo(address collection, address paymentCoin, address recipient, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, paymentCoin, recipient, amount);
    }

    function _batchMint(address collection, address paymentCoin, address recipient, uint256 amount)
        internal
        nonReentrant
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        require(amount > 0, "ZERO_AMOUNT");
        Parameters memory params = _parameters[collection];
        require(_stablecoinEnabled(params.enabledCoins, paymentCoin), "STABLECOIN_NOT_ENABLED");
        uint256 subtotalPrice = params.price * amount;
        uint256 totalCost = mintPriceToStablecoinAmount(subtotalPrice, paymentCoin);

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
}

// need base IERC20 for SafeERC20 to wrap
// need IERC20Metadata for `decimals()`
interface IERC20 is IERC20Base, IERC20Metadata {}
