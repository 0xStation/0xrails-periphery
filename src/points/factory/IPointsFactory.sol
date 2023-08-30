// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IPointsFactory {
    event PointsUpdated(address indexed pointsImpl);
    event PointsCreated(address indexed points);

    error InvalidImplementation();

    function pointsImpl() external view returns (address);

    function initialize(address pointsImpl_, address owner_) external;

    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address points);
}
