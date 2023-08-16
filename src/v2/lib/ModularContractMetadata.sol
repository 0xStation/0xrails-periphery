// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMetadataRouter} from "../metadataRouter/IMetadataRouter.sol";

contract ModularContractMetadata {
    address public immutable metadataRouter;

    constructor(address router) {
        metadataRouter = router;
    }

    function contractURI() public view returns (string memory uri) {
        return IMetadataRouter(metadataRouter).contractURI(address(this));
    }
}
