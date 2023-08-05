// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMetadataURIExtension {
    // views
    function ext_contractURI() external view returns (string memory uri);
    function ext_moduleURI() external view returns (string memory uri);
    function ext_guardURI() external view returns (string memory uri);
    function ext_extensionURI() external view returns (string memory uri);
    function ext_collectionURI() external view returns (string memory uri);
    function ext_tokenURI(uint256 tokenId) external view returns (string memory uri);
}
