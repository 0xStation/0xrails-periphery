// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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

    function _registerFeeBatch(uint256 n) internal returns (uint256 paidFee) {
        paidFee = fee * n; // read from state once, gas optimization
        if (paidFee != msg.value) revert InvalidFee(paidFee, msg.value);
        feeBalance += paidFee;
    }
}
