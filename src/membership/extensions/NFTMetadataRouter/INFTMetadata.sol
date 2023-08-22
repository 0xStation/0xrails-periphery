// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface INFTMetadata {
    // views
    function ext_contractURI() external view returns (string memory uri);
    function ext_tokenURI(uint256 tokenId) external view returns (string memory uri);
}
