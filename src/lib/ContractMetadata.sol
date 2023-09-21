// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMetadataRouter} from "../metadataRouter/IMetadataRouter.sol";

contract ContractMetadata {
    address public immutable metadataRouter;

    constructor(address router) {
        metadataRouter = router;
    }

    /// @dev Returns the contract URI for this contract, a modern standard for NFTs
    /// @notice Intended to be invoked in the context of a delegatecall
    function contractURI() public view virtual returns (string memory uri) {
        return IMetadataRouter(metadataRouter).uriOf(_contractRoute(), address(this));
    }

    function _contractRoute() internal pure virtual returns (string memory route) {
        return "contract";
    }
}
