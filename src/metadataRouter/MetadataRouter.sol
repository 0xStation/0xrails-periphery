// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "mage/access/ownable/Ownable.sol";

import {IMetadataRouter} from "./IMetadataRouter.sol";

contract MetadataRouter is Ownable, UUPSUpgradeable, IMetadataRouter {
    using Strings for uint256;

    /*=============
        STORAGE
    ==============*/

    string public defaultURI;
    mapping(string => string) public routeURI;
    mapping(string => mapping(address => string)) public contractRouteURI;

    /*====================
        INITIALIZATION
    ====================*/

    /// @dev todo: change to initializer and use public functions to emit events
    constructor(address _owner, string memory defaultURI_, string[] memory routes, string[] memory routeURIs) {
        uint256 len = routes.length;
        if (len != routeURIs.length) revert();

        for (uint256 i; i < len; i++) {
            routeURI[routes[i]] = routeURIs[i];
            emit RouteURIUpdated(routes[i], routeURIs[i]);
        }

        defaultURI = defaultURI_;
        emit DefaultURIUpdated(defaultURI_);

        _transferOwnership(_owner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*===========
        VIEWS
    ===========*/

    // metadata for this MetadataRouter contract
    function contractURI() external view returns (string memory uri) {
        return _getContractRouteURI("contract", address(this));
    }

    function baseURI(string memory route, address contractAddress) public view returns (string memory uri) {
        uri = contractRouteURI[route][contractAddress];
        if (bytes(uri).length == 0) {
            uri = routeURI[route];
            if (bytes(uri).length == 0) {
                uri = defaultURI;
            }
        }
    }

    function _getContractRouteURI(string memory route, address contractAddress)
        internal
        view
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                baseURI(route, contractAddress),
                "?chainId=",
                Strings.toString(block.chainid),
                "&contractAddress=",
                Strings.toHexString(uint160(contractAddress), 20)
            )
        );
    }

    /*====================
        CORE UTILITIES
    ====================*/

    function setDefaultURI(string memory uri) external onlyOwner {
        defaultURI = uri;
        emit DefaultURIUpdated(uri);
    }

    function setRouteURI(string memory route, string memory uri) external onlyOwner {
        routeURI[route] = uri;
        emit RouteURIUpdated(route, uri);
    }

    function setContractRouteURI(string memory route, string memory uri, address contractAddress)
        external
        onlyOwner
    {
        contractRouteURI[route][contractAddress] = uri;
        emit ContractRouteURIUpdated(route, uri, contractAddress);
    }

    /*============
        ROUTES
    ============*/

    function uriOf(string memory route, address contract_) public view returns (string memory) {
        return _getContractRouteURI(route, contract_);
    }
    
    function uriOf(string memory route, address contract_, string memory appendData) public view returns (string memory) {
        return string(abi.encodePacked(_getContractRouteURI(route, contract_), appendData));
    }

    function tokenURI(address collection, uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(_getContractRouteURI("token", collection), "&tokenId=", Strings.toString(tokenId)));
    }
}
