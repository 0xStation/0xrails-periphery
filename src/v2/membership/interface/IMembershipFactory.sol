// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IMembershipFactory {
    event MembershipCreated(address indexed membership);

    function membershipImpl() external view returns (address);

    function initialize(address membershipImpl_, address owner_) external;

    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address membership);
}
