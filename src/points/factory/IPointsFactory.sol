// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IPointsFactory {
    event PointsUpdated(address indexed pointsImpl);
    event PointsCreated(address indexed points);

    error InvalidImplementation();

    /// @dev Get the current implementation contract
    function pointsImpl() external view returns (address);

    /// @dev Set the `newImpl` address whose logic will be used by deployed Points proxies
    function setPointsImpl(address newImpl) external;

    /// @dev Initializes the proxy for the factory
    /// @param pointsImpl_ The initial Points implementation address whose logic to use
    /// @param owner_ The owner address to be set for the factory contract
    function initialize(address pointsImpl_, address owner_) external;

    /// @dev Function to create a new Points proxy using given data
    /// @param owner The owner address to be set for the new Points
    /// @param name The points name string
    /// @param symbol The points symbol string
    /// @param initData Data to pass to `initialize()` on the created Points proxy
    /// @return points The created Points proxy address
    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address points);
}
