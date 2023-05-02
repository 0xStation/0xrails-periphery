// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMembership {
    event UpdatedRenderer(address indexed renderer);

    function updateRenderer(address _renderer) external;
    function mintTo(address recipient, uint256 tokenId) external;
    function burnFrom(uint256 tokenId) external;
}
