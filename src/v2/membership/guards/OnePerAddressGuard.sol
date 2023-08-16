// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IGuard} from "lib/mage/src/guard/interface/IGuard.sol";
import {IERC721} from "lib/mage/src/cores/ERC721/IERC721.sol";

import {ModularContractMetadata} from "../../lib/ModularContractMetadata.sol";

contract OnePerAddressGuard is ModularContractMetadata, IGuard {
    error OnePerAddress(address owner, uint256 balance);
    
    constructor(address metadataRouter) ModularContractMetadata(metadataRouter) {}

    function checkBefore(address, bytes calldata data) external view returns (bytes memory checkBeforeData) {
        // (address from, address to, uint256 startTokenId, uint256 quantity)
        (,address owner,,uint256 quantity) = abi.decode(data, (address, address, uint256, uint256)); 

        uint256 balanceBefore = IERC721(msg.sender).balanceOf(owner);
        if (balanceBefore + quantity > 1) {
            revert OnePerAddress(owner, balanceBefore + quantity);
        }

        return abi.encode(owner); // only need to pass the owner forward to checkAfter
    }

    function checkAfter(bytes calldata checkBeforeData, bytes calldata) external view {
        address owner = abi.decode(checkBeforeData, (address));
        uint256 balanceAfter = IERC721(msg.sender).balanceOf(owner);
        if (balanceAfter > 1) revert OnePerAddress(owner, balanceAfter);
    }
}