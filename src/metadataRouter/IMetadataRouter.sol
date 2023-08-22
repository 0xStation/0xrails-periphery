// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMetadataRouter {
    // events
    event DefaultURIUpdated(string uri);
    event RouteURIUpdated(string route, string uri);
    event ContractRouteURIUpdated(string route, string uri, address indexed contractAddress);

    // views
    function baseURI(string memory route, address contractAddress) external view returns (string memory);
    function defaultURI() external view returns (string memory);
    function routeURI(string memory route) external view returns (string memory);
    function contractRouteURI(string memory route, address contractAddress) external view returns (string memory);
    function uriOf(string memory route, address contractAddress) external view returns (string memory);
    function uriOf(string memory route, address contractAddress, string memory appendData)
        external
        view
        returns (string memory);
    // specific routes
    function tokenURI(address collection, uint256 tokenId) external view returns (string memory);

    // setters
    function setDefaultURI(string memory uri) external;
    function setRouteURI(string memory uri, string memory route) external;
    function setContractRouteURI(string memory uri, string memory route, address contractAddress) external;
}
