// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract FeeModule is Ownable {
    uint256 public fee;
    uint256 public feeBalance;

    event FeeUpdated(uint256 fee);
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
        emit FeeUpdated(newFee);
    }

    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = feeBalance;
        feeBalance = 0;
        payable(recipient).transfer(balance);
        emit WithdrawFee(recipient, balance);
    }

    function _registerFee() internal returns (uint256 paidFee) {
        paidFee = fee; // read from state once, gas optimization
        require(msg.value == paidFee, "INVALID_FEE");
        feeBalance += paidFee;
    }
}
