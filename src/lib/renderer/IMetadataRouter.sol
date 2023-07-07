// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMetadataRouter {
    error UnauthorizedOverride(address sender, string contractType, address contractAddress);

    event UpdateDefaultBaseURI(string contractType, string uri);
    event OverrideBaseURI(string contractType, string uri, address indexed contractAddress);

    // base config
    function updateDefaultURI(string memory contractType, string memory uri) external;
    function defaultURI(string memory contractType) external returns (string memory);
    function overrideBaseURI(string memory contractType, string memory uri, address contractAddress) external;
    function baseURI(string memory contractType, address contractAddress) external returns (string memory);
    // fetch subject-specific endpoints
    function tokenURI(address collection, uint256 tokenId) external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function collectionURI(address collection) external view returns (string memory);
    function collectionURI() external view returns (string memory);
    function moduleURI(address collection) external view returns (string memory);
    function moduleURI() external view returns (string memory);
}
