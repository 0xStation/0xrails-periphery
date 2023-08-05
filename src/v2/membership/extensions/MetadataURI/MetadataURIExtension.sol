// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMetadataURIExtension} from "./IMetadataURIExtension.sol";
import {IMetadataRouter} from "../../../metadataRouter/IMetadataRouter.sol";

abstract contract MetadataURIExtension {
    /// @dev change metadataRouter constant to real address prior to deploying
    address public constant metadataRouter = address(0);

    function contractURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).contractURI(address(this));
    }

    /*===========
        VIEWS
    ===========*/

    function ext_contractURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).contractURI(address(this));
    }

    function ext_moduleURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).moduleURI(address(this));
    }

    function ext_guardURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).guardURI(address(this));
    }

    function ext_extensionURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).extensionURI(address(this));
    }

    function ext_collectionURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).collectionURI(address(this));
    }

    function ext_tokenURI(uint256 tokenId) external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).tokenURI(address(this), tokenId);
    }
}
