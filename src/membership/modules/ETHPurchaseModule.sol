// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Membership} from "src/membership/Membership.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract ETHPurchaseModule is Ownable {
    mapping(address => uint256) public prices;
    mapping(address => uint256) public balances;
    uint256 public fee;
    uint256 public feeBalance;

    event Purchase(address indexed collection, address indexed buyer, uint256 price, uint256 fee);
    event Withdraw(address indexed collection, address indexed recipient, uint256 amount);
    event WithdrawFee(address indexed recipient, uint256 amount);

    constructor(address _owner, uint256 _fee) {
        _transferOwnership(_owner);
        fee = _fee;
    }

    function setup(address collection, uint256 price) external {
        require(msg.sender == collection || msg.sender == Ownable(collection).owner(), "NOT_ALLOWED");
        prices[collection] = price;
    }

    function updateFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }

    function mint(address collection) external payable {
        uint256 price = prices[collection];
        uint256 totalCost = price + fee;
        require(msg.value >= totalCost, "INSUFFICIENT_ETH");

        feeBalance += fee;
        balances[collection] += price;
        (uint256 tokenId) = IMembership(collection).mintTo(msg.sender);
        require(tokenId > 0, "MINT_FAILED");
        emit Purchase(collection, msg.sender, price, fee);
    }

    function withdraw(address collection) external {
        address recipient = Membership(collection).paymentCollector();
        uint256 balance = balances[collection];
        balances[collection] = 0;
        payable(recipient).transfer(balance);
        emit Withdraw(collection, recipient, balance);
    }

    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = feeBalance;
        feeBalance = 0;
        payable(recipient).transfer(balance);
        emit WithdrawFee(recipient, balance);
    }
}
