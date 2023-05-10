// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MembershipStorageV0 {
    // augment `tokenURI` through a Renderer contract
    address public renderer;
    // self-incrementing id for minting tokens, doubly functions as totalSupply function
    uint256 public totalSupply;
    // Permissions.Operation => Guard smart contract, applies additional invariant constraints per operation
    // address(0) represents no constraints, address(max) represents full constraints = not allowed
    mapping(uint8 => address) internal guards;
}
