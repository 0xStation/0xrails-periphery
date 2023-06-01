// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract FixedStablecoinPurchaseModule is Ownable {
    // collection -> price in currency
    mapping(address => uint256) public stablecoinPrices;
    // collection -> bitmap of stables that are enabled
    mapping(address => bytes32) public enabledCoins;
    // stablecoin address -> key in bitmap
    mapping(address => uint8) public stablecoinKey;
    // station fee
    uint256 public fee;
    // current balance of station fee to be withdrawn
    uint256 public feeBalance;
    // how many keys currently exist in map
    uint8 public keyCounter;
    // decimals of percision for currency type
    uint8 public decimals;
    // currency type for this particular contract. (USD, EUR, etc.)
    string public currency;

    event Purchase(
        address indexed collection, address indexed buyer, address indexed paymentToken, uint256 price, uint256 fee
    );
    event WithdrawFee(address indexed recipient, uint256 amount);

    constructor(address _owner, uint256 _fee, string memory _currency, uint8 _decimals) {
        _transferOwnership(_owner);
        fee = _fee;
        currency = _currency;
        decimals = _decimals;
    }

    function setup(address collection, uint256 price, bytes32 enabled) external {
        require(msg.sender == Ownable(collection).owner(), "NOT_ALLOWED");
        _setup(collection, price, enabled);
    }

    function setup(uint256 price, bytes32 enabled) external {
        _setup(msg.sender, price, enabled);
    }

    function _setup(address collection, uint256 price, bytes32 enabled) internal {
        stablecoinPrices[collection] = price;
        enabledCoins[collection] = enabled;
    }

    function append(address token) external onlyOwner {
        uint8 newKey = ++keyCounter;
        stablecoinKey[token] = newKey;
    }

    function updateFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }

    function mint(address collection, address token) external payable {
        _mint(collection, token, msg.sender);
    }

    function mintTo(address collection, address token, address to) external payable {
        _mint(collection, token, to);
    }

    function _mint(address collection, address token, address to) internal {
        require(stablecoinEnabled(collection, token), "TOKEN NOT ENABLED BY COLLECTION");
        uint256 price = stablecoinPrices[collection];
        uint256 totalCost = getMintPrice(token, price);
        require(msg.value == fee, "MISSING_FEE");
        feeBalance += fee;
        address recipient = IMembership(collection).paymentCollector();
        IERC20(token).transferFrom(msg.sender, recipient, totalCost);
        (uint256 tokenId) = IMembership(collection).mintTo(to);
        require(tokenId > 0, "MINT_FAILED");
        emit Purchase(collection, to, token, price, fee);
    }

    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = feeBalance;
        feeBalance = 0;
        payable(recipient).transfer(balance);
        emit WithdrawFee(recipient, balance);
    }

    function keyOf(address token) public view returns (uint8 key) {
        key = stablecoinKey[token];
        require(key != 0, "STABLECOIN_NOT_SUPPORTED");
    }

    function stablecoinEnabled(address collection, address token) public view returns (bool) {
        bytes32 _bitmap = enabledCoins[collection];
        return (_bitmap & _tokenBit(token)) != 0;
    }

    function enabledTokensValue(address[] memory enabledTokens) external view returns (bytes32 value) {
        for (uint256 i; i < enabledTokens.length; i++) {
            value |= _tokenBit(enabledTokens[i]);
        }
    }

    function _tokenBit(address token) internal view returns (bytes32) {
        return bytes32(1 << uint8(keyOf(token)));
    }

    function getMintPrice(address token, uint256 mintPrice) public view returns (uint256) {
        uint256 tokenDecimals = IERC20(token).decimals();
        if (decimals < tokenDecimals) {
            // need to pad zeros to input amount
            return mintPrice * 10 ** (tokenDecimals - decimals);
        } else if (decimals > tokenDecimals) {
            // need to remove zeros from mintPrice
            return mintPrice / 10 ** (decimals - tokenDecimals);
        } else {
            // chosen token (stablecoin) and contract currency have same decimals, no need to do anything.
            return mintPrice;
        }
    }
}

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function decimals() external view returns (uint8);
    function balanceOf(address owner) external view returns (uint256 balance);
}
