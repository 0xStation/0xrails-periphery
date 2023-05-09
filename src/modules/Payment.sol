// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../membership/IMembership.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";


contract PaymentModule {
    address public feeCollectorAddress;
    mapping(address => uint256) public costs;
    mapping(address => address) public paymentCollectors;
    mapping(address => uint256) public balances;
    uint256 constant FEE = 0.0007 ether;

    constructor(address _feeCollectorAddress) {
        feeCollectorAddress = _feeCollectorAddress;
    }

    function addCollection(address collection, uint256 cost, address paymentCollector) external {
        require(msg.sender == Ownable(collection).owner(), "NOT_OWNER");
        costs[collection] = cost;
        paymentCollectors[collection] = paymentCollector;
    }

    function mint(address collection) payable external {
        uint256 cost = costs[collection];
        uint256 totalCost = cost + FEE;
        require(msg.value >= totalCost, "Not enough ETH sent.");

        // payable(feeCollectorAddress).transfer(FEE);
        // payable(paymentCollectors[collection]).transfer(cost);

        balances[feeCollectorAddress] += FEE;
        balances[collection] += cost;
        IMembership(collection).mintTo(msg.sender);
    }

    function withdraw(address collection) external {
        require(msg.sender == Ownable(collection).owner(), "NOT_OWNER");
        uint256 balance = balances[collection];
        require(balance > 0, "No balance to withdraw.");
        balances[collection] = 0;
        payable(paymentCollectors[collection]).transfer(balance);
    }

    function withdrawFee() external {
        require(msg.sender == feeCollectorAddress, "NOT_FEE_COLLECTOR");
        uint256 balance = balances[feeCollectorAddress];
        require(balance > 0, "No balance to withdraw.");
        balances[feeCollectorAddress] = 0;
        payable(feeCollectorAddress).transfer(balance);
    }
}
