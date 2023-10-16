// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface AccountGroup {
    event SubgroupInitializationUpdated(uint64 indexed subgroupId, address indexed accountImpl, address indexed initializer);

    function initialize(address owner, address initializerImpl) external;
}
