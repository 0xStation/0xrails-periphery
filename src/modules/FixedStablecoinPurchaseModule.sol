// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "../membership/IMembership.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract FixedStablecoinPurchaseModule is Ownable {
    // collection -> price in currency
    mapping(address => uint256) public stablecoinPrices;
    // collection -> bitmap of stables that are enabled
    mapping(address => bytes32) enabledCoins;
    // stablecoin address -> key in bitmap
    mapping(address => uint8) stablecoinKey;
    // collection -> payment collector able to widraw balance
    mapping(address => address) public paymentCollectors;
    // station fee
    uint256 public fee;
    // current balance of station fee to be withdrawn
    uint256 public feeBalance;
    // how many keys currently exist in map
    uint8 public keyCounter;
    // currency type for this particular contract. (USD, EUR, etc.)
    string public currency;

    event Purchase(address indexed collection, address indexed buyer, uint256 price, uint256 fee);
    event WithdrawFee(address indexed recipient, uint256 amount);

    constructor(address _owner, uint256 _fee, string memory _currency) {
        _transferOwnership(_owner);
        fee = _fee;
        currency = _currency;
    }

    function setup(address collection, address paymentCollector, uint256 price) external {
        require(msg.sender == collection || msg.sender == Ownable(collection).owner(), "NOT_ALLOWED");
        stablecoinPrices[collection] = price;
        paymentCollectors[collection] = paymentCollector;
    }

    function append(address token) external onlyOwner {
        uint8 newKey = keyCounter++;
        stablecoinKey[token] = newKey;
    }

    function updateFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }

    function mint(address collection, address token) external payable {
        require(_stablecoinEnabled(collection, token), "TOKEN NOT SUPPORTED");
        uint256 price = stablecoinPrices[collection];
        uint256 totalCost = getMintAmount(token, price);
        require(msg.value >= fee, "MISSING FEE");
        feeBalance += fee;
        IERC20(token).transfer(paymentCollectors[collection], totalCost);
        (uint256 tokenId) = IMembership(collection).mintTo(msg.sender);
        require(tokenId > 0, "MINT_FAILED");
        emit Purchase(collection, msg.sender, price, fee);
    }

    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = feeBalance;
        feeBalance = 0;
        payable(recipient).transfer(balance);
        emit WithdrawFee(recipient, balance);
    }

    function _permit(address collection, bytes32 _bitmap) internal {
        enabledCoins[collection] = _bitmap;
    }

    function _stablecoinEnabled(address collection, address token) public view returns(bool) {
        bytes32 _bitmap = enabledCoins[collection];
        uint8 key = stablecoinKey[token];
        uint256 bitmapUint = uint256(_bitmap);
        return (bitmapUint & (1 << key)) != 0;

    }

    function getMintAmount(address token, uint256 depositAmount) public view returns (uint256) {
        uint256 tokenDecimals = IERC20(token).decimals();
        return depositAmount * 10**(tokenDecimals);
    }
}

interface IERC20 {
  function transfer(address _to, uint256 _value) external returns (bool success);
  function decimals() external view returns (uint8);
}
