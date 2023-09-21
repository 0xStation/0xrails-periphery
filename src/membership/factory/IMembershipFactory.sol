// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IMembershipFactory {
    event MembershipUpdated(address indexed membershipImpl);
    event MembershipCreated(address indexed membership);

    error InvalidImplementation();

    /// @dev Get the current implementation contract
    function membershipImpl() external view returns (address);

    /// @dev Set the `newImpl` address whose logic will be used by deployed Membership proxies
    function setMembershipImpl(address newImpl) external;

    /// @dev Initializes the proxy for the factory
    /// @param membershipImpl_ The initial Membership implementation address whose logic to use
    /// @param owner_ The owner address to be set for the factory contract
    function initialize(address membershipImpl_, address owner_) external;

    /// @dev Function to create a new Membership proxy using given data
    /// @param owner The owner address to be set for the new Membership
    /// @param name The membership name string
    /// @param symbol The membership symbol string
    /// @param initData Data to pass to `initialize()` on the created Membership proxy
    /// @return membership The created Membership proxy address
    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address membership);
}
