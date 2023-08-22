// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMembership {
    function initialize(address owner, string calldata name, string calldata symbol, bytes calldata initData)
        external;
}
