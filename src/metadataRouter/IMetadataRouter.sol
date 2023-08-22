// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMetadataRouter {
    // events
    event UpdateBaselineURI(string uri);
    event UpdateDefaultURI(string contractType, string uri);
    event UpdateCustomURI(string contractType, string uri, address indexed contractAddress);

    // views
    function baselineURI() external returns (string memory);
    function defaultURI(string memory contractType) external returns (string memory);
    function customURI(string memory contractType, address contractAddress) external returns (string memory);
    function baseURI(string memory contractType, address contractAddress) external returns (string memory);

    // setters
    function updateBaselineURI(string memory uri) external;
    function updateDefaultURI(string memory uri, string memory contractType) external;
    function updateCustomURI(string memory uri, string memory contractType, address contractAddress) external;

    // routes
    function contractURI(address contractAddress) external view returns (string memory);
    function moduleURI(address module) external view returns (string memory);
    function guardURI(address guard) external view returns (string memory);
    function extensionURI(address extension) external view returns (string memory);
    function collectionURI(address collection) external view returns (string memory);
    function tokenURI(address collection, uint256 tokenId) external view returns (string memory);
}
