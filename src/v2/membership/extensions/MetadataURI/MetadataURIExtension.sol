// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Extension} from "mage/extension/Extension.sol";

import {IMetadataURIExtension} from "./IMetadataURIExtension.sol";
import {IMetadataRouter} from "../../../metadataRouter/IMetadataRouter.sol";
import {ContractMetadata} from "../../../lib/ContractMetadata.sol";

contract MetadataURIExtension is Extension, ContractMetadata {
    constructor(address router) Extension() ContractMetadata(router) {}

    /*===============
        EXTENSION
    ===============*/

    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](12);
        selectors[0] = this.contractURI.selector;
        selectors[1] = this.moduleURI.selector;
        selectors[2] = this.guardURI.selector;
        selectors[3] = this.extensionURI.selector;
        selectors[4] = this.collectionURI.selector;
        selectors[5] = this.tokenURI.selector;
        selectors[6] = this.ext_contractURI.selector;
        selectors[7] = this.ext_moduleURI.selector;
        selectors[8] = this.ext_guardURI.selector;
        selectors[9] = this.ext_extensionURI.selector;
        selectors[10] = this.ext_collectionURI.selector;
        selectors[11] = this.ext_tokenURI.selector;
        return selectors;
    }

    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.contractURI.selector) {
            return "contractURI()";
        } else if (selector == this.moduleURI.selector) {
            return "moduleURI()";
        } else if (selector == this.guardURI.selector) {
            return "guardURI()";
        } else if (selector == this.extensionURI.selector) {
            return "extensionURI()";
        } else if (selector == this.collectionURI.selector) {
            return "collectionURI()";
        } else if (selector == this.tokenURI.selector) {
            return "tokenURI(uint256)";
        } else if (selector == this.ext_contractURI.selector) {
            return "ext_contractURI()";
        } else if (selector == this.ext_moduleURI.selector) {
            return "ext_moduleURI()";
        } else if (selector == this.ext_guardURI.selector) {
            return "ext_guardURI()";
        } else if (selector == this.ext_extensionURI.selector) {
            return "ext_extensionURI()";
        } else if (selector == this.ext_collectionURI.selector) {
            return "ext_collectionURI()";
        } else if (selector == this.ext_tokenURI.selector) {
            return "ext_tokenURI(uint256)";
        } else {
            return "";
        }
    }

    /*===========
        VIEWS
    ===========*/

    // double counts for this extension and dependent mage contracts
    // call for this extension's contract metadata
    // delegatecall for the mage's contract metadata
    function contractURI() public view override returns (string memory uri) {
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
