// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "mage/access/ownable/Ownable.sol";
import {Initializable} from "mage/lib/initializable/Initializable.sol";

import {IMetadataRouter} from "./IMetadataRouter.sol";
import {MetadataRouterStorage} from "./MetadataRouterStorage.sol";

contract MetadataRouter is Initializable, Ownable, UUPSUpgradeable, IMetadataRouter {
    using Strings for uint256;

    /*====================
        INITIALIZATION
    ====================*/

    constructor() Initializable() {}

    function initialize(address _owner, string memory defaultURI_, string[] memory routes, string[] memory routeURIs) external initializer {
        uint256 len = routes.length;
        if (len != routeURIs.length) revert();

        MetadataRouterStorage.Layout storage layout = MetadataRouterStorage.layout();

        for (uint256 i; i < len; i++) {
            layout.routeURI[routes[i]] = routeURIs[i];
            emit RouteURIUpdated(routes[i], routeURIs[i]);
        }

        layout.defaultURI = defaultURI_;
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
        MetadataRouterStorage.Layout storage layout = MetadataRouterStorage.layout();
        uri = layout.contractRouteURI[route][contractAddress];
        if (bytes(uri).length == 0) {
            uri = layout.routeURI[route];
            if (bytes(uri).length == 0) {
                uri = layout.defaultURI;
            }
        }
        return uri;
    }

    function defaultURI() external view returns (string memory) {
        return MetadataRouterStorage.layout().defaultURI;
    }
    
    function routeURI(string memory route) external view returns (string memory) {
        MetadataRouterStorage.layout().routeURI[route];
    }
    
    function contractRouteURI(string memory route, address contractAddress) external view returns (string memory) {
        MetadataRouterStorage.layout().contractRouteURI[route][contractAddress];
    }

    function _getContractRouteURI(string memory route, address contractAddress) internal view returns (string memory) {
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
        MetadataRouterStorage.Layout storage layout = MetadataRouterStorage.layout();
        layout.defaultURI = uri;
        emit DefaultURIUpdated(uri);
    }

    function setRouteURI(string memory route, string memory uri) external onlyOwner {
        MetadataRouterStorage.Layout storage layout = MetadataRouterStorage.layout();
        layout.routeURI[route] = uri;
        emit RouteURIUpdated(route, uri);
    }

    function setContractRouteURI(string memory route, string memory uri, address contractAddress) external onlyOwner {
        MetadataRouterStorage.Layout storage layout = MetadataRouterStorage.layout();
        layout.contractRouteURI[route][contractAddress] = uri;
        emit ContractRouteURIUpdated(route, uri, contractAddress);
    }

    /*============
        ROUTES
    ============*/

    function uriOf(string memory route, address contract_) public view returns (string memory) {
        return _getContractRouteURI(route, contract_);
    }

    function uriOf(string memory route, address contract_, string memory appendData)
        public
        view
        returns (string memory)
    {
        return string(abi.encodePacked(_getContractRouteURI(route, contract_), appendData));
    }

    function tokenURI(address collection, uint256 tokenId) public view returns (string memory) {
        return
            string(abi.encodePacked(_getContractRouteURI("token", collection), "&tokenId=", Strings.toString(tokenId)));
    }
}
