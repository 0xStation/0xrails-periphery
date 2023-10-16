// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAccountGroup {
    event SubgroupInitializerUpdated(uint64 indexed subgroupId, address indexed initializer);

    function initialize(address owner) external;
    function setAccountInitializer(uint64 subgroupId, address initializer) external;
}
