// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {INFTMetadata} from "./INFTMetadata.sol";
import {IMetadataRouter} from "../../../metadataRouter/IMetadataRouter.sol";
import {ContractMetadata} from "../../../lib/ContractMetadata.sol";

contract NFTMetadataRouter is ContractMetadata, INFTMetadata {

    constructor(address router) ContractMetadata(router) {}

    /*===========
        VIEWS
    ===========*/

    function ext_contractURI() external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).uriOf("collection", address(this));
    }

    function ext_tokenURI(uint256 tokenId) external view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).tokenURI(address(this), tokenId);
    }
}
