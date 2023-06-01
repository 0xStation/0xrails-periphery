// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Batch} from "src/lib/Batch.sol";

interface IMembership {
    event UpdatedRenderer(address indexed renderer);
    event UpdatedPaymentCollector(address indexed paymentCollector);

    function init(address newOwner, address newRenderer, string memory newName, string memory newSymbol) external;
    function updateRenderer(address _renderer) external returns (bool success);
    function mintTo(address recipient) external returns (uint256 tokenId);
    function burnFrom(uint256 tokenId) external returns (bool success);
    function burn(uint256 tokenId) external returns (bool success);
    function renderer() external returns (address renderer);
    function totalSupply() external returns (uint256 totalSupply);
    function paymentCollector() external returns (address paymentCollector);
}
