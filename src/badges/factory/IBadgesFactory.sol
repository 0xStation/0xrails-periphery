// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IBadgesFactory {
    event BadgesUpdated(address indexed badgesImpl);
    event BadgesCreated(address indexed badges);

    error InvalidImplementation();

    /// @dev Get the current implementation contract
    function badgesImpl() external view returns (address);
    
    /// @dev Set the `newImpl` address whose logic will be used by deployed Badge proxies
    function setBadgesImpl(address newImpl) external;

    /// @dev Initializes the proxy for the factory
    /// @param owner_ The owner address to be set for the factory contract
    /// @param badgesImpl- The initial Badge implementation address whose logic to use
    function initialize(address badgesImpl_, address owner_) external;

    /// @dev Function to create a new Badge proxy using given data
    /// @param owner The owner address to be set for the new Badge
    /// @param name The badge name string
    /// @param symbol The badge symbol string
    /// @param initData Data to pass to `initialize()` on the created Badge proxy
    /// @return badges The created Badge proxy address
    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address badges);
}
