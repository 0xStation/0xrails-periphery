// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface ITokenFactory {

    enum TokenStandard {
        ERC20,
        ERC721,
        ERC1155
    }

    event ERC721RailsCreated(address indexed membership);
    event ERC20RailsCreated(address indexed points);
    event ERC1155RailsCreated(address indexed badges);

    error InvalidImplementation();

    /// @dev Initializes the proxy for the factory
    /// @param owner_ The owner address to be set for the factory contract
    function initialize(address owner_) external;

    /// @dev Function to create a new core token proxy using given data
    /// @param std The token type to be dpeloyed
    /// @param coreImpl The logic implementation address to be set for the created proxy
    /// @param owner The owner address to be set for the new token proxy
    /// @param name The token name string
    /// @param symbol The token symbol string
    /// @param initData Data to pass to `initialize()` on the created token proxy
    /// @return core The created token proxy address
    function create(
        TokenStandard std, 
        address payable coreImpl, 
        address owner, 
        string memory name, 
        string memory symbol, 
        bytes calldata initData
    ) external returns (address payable core);
}
