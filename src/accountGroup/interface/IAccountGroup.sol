// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAccountGroup {
    event SubgroupInitializationUpdated(uint64 indexed subgroupId, address indexed accountImpl, address indexed initializer);

    function initialize(address owner, address initializerImpl) external;
    function getAccountImplementation(address account) external view returns (address);
}
