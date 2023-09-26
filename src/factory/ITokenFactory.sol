// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface ITokenFactory {

    event MembershipUpdated(address indexed membershipImpl);
    event MembershipCreated(address indexed membership);
    event PointsUpdated(address indexed pointsImpl);
    event PointsCreated(address indexed points);
    event BadgesUpdated(address indexed badgesImpl);
    event BadgesCreated(address indexed badges);

    error InvalidImplementation();

    /// @dev Initializes the proxy for the factory
    /// @param membershipImpl_ The initial Membership implementation address whose logic to use
    /// @param pointsImpl_ The initial Points implementation address whose logic to use
    /// @param badgesImpl_ The initial Badge implementation address whose logic to use
    /// @param owner_ The owner address to be set for the factory contract
    function initialize(address membershipImpl_, address pointsImpl_, address badgesImpl_, address owner_) external;

    /// @dev Get the current ERC721Rails implementation contract
    function membershipImpl() external view returns (address);
    /// @dev Get the current implementation contract
    function pointsImpl() external view returns (address);
    /// @dev Get the current ERC1155Rails implementation contract
    function badgesImpl() external view returns (address);
    
    /// @dev Set the `newImpl` address whose logic will be used by deployed Membership proxies
    function setMembershipImpl(address newImpl) external;
    /// @dev Set the `newImpl` address whose logic will be used by deployed Points proxies
    function setPointsImpl(address newImpl) external;
    /// @dev Set the `newImpl` address whose logic will be used by deployed Badge proxies
    function setBadgesImpl(address newImpl) external;

    /// @dev Function to create a new Membership proxy using given data
    /// @param owner The owner address to be set for the new Membership
    /// @param name The membership name string
    /// @param symbol The membership symbol string
    /// @param initData Data to pass to `initialize()` on the created Membership proxy
    /// @return membership The created Membership proxy address
    function createMembership(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address membership);

    /// @dev Function to create a new Points proxy using given data
    /// @param owner The owner address to be set for the new Points
    /// @param name The points name string
    /// @param symbol The points symbol string
    /// @param initData Data to pass to `initialize()` on the created Points proxy
    /// @return points The created Points proxy address
    function createPoints(address owner, string memory name, string memory symbol, bytes calldata initData)
    external
    returns (address points);

    /// @dev Function to create a new Badge proxy using given data
    /// @param owner The owner address to be set for the new Badge
    /// @param name The badge name string
    /// @param symbol The badge symbol string
    /// @param initData Data to pass to `initialize()` on the created Badge proxy
    /// @return badges The created Badge proxy address
    function createBadges(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address badges);
}
