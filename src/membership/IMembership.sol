// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMembership {
    event UpdatedRenderer(address indexed renderer);

    function initialize(address owner_, address renderer_, string memory name_, string memory symbol_) external returns (bool);
    function updateRenderer(address _renderer) external returns (bool);
    function mintTo(address recipient) external returns (bool);
    function burnFrom(uint256 tokenId) external returns (bool);
}
