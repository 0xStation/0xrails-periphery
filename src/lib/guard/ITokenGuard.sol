// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ITokenGuard {
    function isAllowed(address operator, address from, address to, uint256 value) external returns (bool);
}
