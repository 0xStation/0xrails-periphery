// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract ModuleFee is Ownable {
    uint256 public fee;
    uint256 public feeBalance;

    error InvalidFee(uint256 expected, uint256 received);

    event UpdateFee(uint256 fee);
    event WithdrawFee(address indexed recipient, uint256 amount);

    constructor(address newOwner, uint256 newFee) {
        _transferOwnership(newOwner);
        _updateFee(newFee);
    }

    function updateFee(uint256 newFee) external onlyOwner {
        _updateFee(newFee);
    }

    function _updateFee(uint256 newFee) internal {
        fee = newFee;
        emit UpdateFee(newFee);
    }

    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = feeBalance;
        feeBalance = 0;
        payable(recipient).transfer(balance);
        emit WithdrawFee(recipient, balance);
    }

    function _registerFee() internal returns (uint256 paidFee) {
        return _registerFeeBatch(1);
    }

    function _registerFee(uint256 offset) internal returns (uint256 paidFee) {
        return _registerFeeBatchOffset(1, offset);
    }

    function _registerFeeBatch(uint256 n) internal returns (uint256 paidFee) {
        return _registerFeeBatchOffset(n, 0);
    }

    function _registerFeeBatchOffset(uint256 n, uint256 offset) internal returns (uint256 paidFee) {
        paidFee = fee * n; // read from state once, gas optimization
        if (paidFee + offset != msg.value) revert InvalidFee(paidFee + offset, msg.value);
        feeBalance += paidFee;
    }

    function collectionPaymentCollector(address collection) internal returns (address paymentCollector) {
        paymentCollector = IMembership(collection).paymentCollector();
        // prevent accidentally unset payment collector
        require(paymentCollector != address(0), "MISSING_PAYMENT_COLLECTOR");
    }
}
