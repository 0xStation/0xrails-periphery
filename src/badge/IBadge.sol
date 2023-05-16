// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Batch} from "src/lib/Batch.sol";

interface IBadge {
    event UpdatedRenderer(address indexed renderer);

    function init(address newOwner, address newRenderer, string memory newName, string memory newSymbol) external;
    function updateRenderer(address _renderer) external returns (bool success);
    function mintTo(address recipient, uint256 tokenId, uint256 amount) external returns (bool success);
    function burnFrom(address account, uint256 tokenId, uint256 amount) external returns (bool success);
    function burn(uint256 tokenId, uint256 amount) external returns (bool success);
}
