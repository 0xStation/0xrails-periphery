// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../membership/IMembership.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";


contract FixedETHPurchaseModule is Ownable {
    mapping(address => uint256) public costs;
    mapping(address => address) public paymentCollectors;
    mapping(address => uint256) public balances;
    uint256 public FEE = 0.0007 ether;


    function setup(address collection, address paymentCollector, uint256 cost) external {
        require(msg.sender == Ownable(collection).owner(), "NOT_OWNER");
        costs[collection] = cost;
        paymentCollectors[collection] = paymentCollector;
    }

    function updateFee(uint256 newFee) external onlyOwner {
        FEE = newFee;
    }

    function mint(address collection) payable external {
        uint256 cost = costs[collection];
        uint256 totalCost = cost + FEE;
        require(msg.value >= totalCost, "Not enough ETH sent.");

        balances[owner()] += FEE;
        balances[collection] += cost;
        (bool success) = IMembership(collection).mintTo(msg.sender);
        require(success, "MINT_FAILED");
    }

    function withdraw(address collection) external {
        uint256 balance = balances[collection];
        balances[collection] = 0;
        payable(paymentCollectors[collection]).transfer(balance);
    }

    function withdrawFee() external {
        uint256 balance = balances[owner()];
        balances[owner()] = 0;
        payable(owner()).transfer(balance);
    }
}
