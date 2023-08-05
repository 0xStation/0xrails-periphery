// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMetadataURIExtension} from "./IMetadataURIExtension.sol";
import {IMetadataRouter} from "../../../metadataRouter/IMetadataRouter.sol";

abstract contract MetadataURIExtension {
    /// @dev change metadataRouter constant to real address prior to deploying
    address public constant metadataRouter = address(0);

    /*===========
        VIEWS
    ===========*/

    function contractURI() public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).contractURI(address(this));
    }

    function moduleURI() public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).moduleURI(address(this));
    }

    function guardURI() public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).guardURI(address(this));
    }

    function extensionURI() public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).extensionURI(address(this));
    }

    function collectionURI() public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).collectionURI(address(this));
    }

    function tokenURI(uint256 tokenId) public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).tokenURI(address(this), tokenId);
    }

    function ext_contractURI() public view returns (string memory uri) {
        return contractURI();
    }

    function ext_moduleURI() public view returns (string memory uri) {
        return moduleURI();
    }

    function ext_guardURI() public view returns (string memory uri) {
        return guardURI();
    }

    function ext_extensionURI() public view returns (string memory uri) {
        return extensionURI();
    }

    function ext_collectionURI() public view returns (string memory uri) {
        return collectionURI();
    }

    function ext_tokenURI(uint256 tokenId) public view returns (string memory uri) {
        return tokenURI(tokenId);
    }
}
