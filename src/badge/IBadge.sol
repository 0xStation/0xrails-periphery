// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IBadge {
    event UpdatedRenderer(address indexed renderer);

    function updateRenderer(address _renderer) external;
    function mintTo(address recipient, uint256 tokenId) external;
    function burnFrom(address account, uint256 tokenId, uint256 amount) external;
    function burn(uint256 tokenId, uint256 amount) external;
}
