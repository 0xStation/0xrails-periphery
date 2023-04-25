// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRenderer {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
