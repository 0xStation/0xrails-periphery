// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../membership/IMembership.sol";

contract PaymentModule {
    mapping(address => uint256) public costs;

    function addCollection(address collection, uint256 cost) external {
        costs[collection] = cost;
    }

    function mint(address collection) payable external {
        uint256 cost = costs[collection];
        require(msg.value >= cost, "Not enough ETH sent.");
        IMembership(collection).mintTo(msg.sender);
    }
}
