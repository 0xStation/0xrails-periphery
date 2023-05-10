// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IBadge {
    event UpdatedRenderer(address indexed renderer);

    function init(address _owner, address _renderer, string memory _name, string memory _symbol) external;
    function updateRenderer(address _renderer) external returns (bool);
    function mintTo(address recipient, uint256 tokenId) external returns (bool);
    function burnFrom(address account, uint256 tokenId, uint256 amount) external returns (bool);
    function burn(uint256 tokenId, uint256 amount) external returns (bool);
}
