// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMembership {
    event UpdatedRenderer(address indexed renderer);

    function init(address newOwner, address newRenderer, string memory newName, string memory newSymbol) external;
    function initAndSetup(
        address newOwner,
        address newRenderer,
        string memory newName,
        string memory newSymbol,
        bytes[] calldata setupCalls
    ) external;
    function updateRenderer(address _renderer) external returns (bool success);
    function mintTo(address recipient) external returns (uint256 tokenId);
    function burnFrom(uint256 tokenId) external returns (bool success);
    function burn(uint256 tokenId) external returns (bool success);
}
