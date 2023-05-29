// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "../membership/IMembership.sol";
import {FeeModule} from "../lib/module/FeeModule.sol";

contract PublicFreeMintModule is FeeModule {
    event Mint(address indexed collection, address indexed recipient, uint256 fee);

    constructor(address newOwner, uint256 newFee) FeeModule(newOwner, newFee) {}

    function mint(address collection) external payable returns (uint256 tokenId) {
        tokenId = _mint(collection, msg.sender);
    }

    function mintTo(address collection, address recipient) external payable returns (uint256 tokenId) {
        tokenId = _mint(collection, recipient);
    }

    function _mint(address collection, address recipient) internal returns (uint256 tokenId) {
        uint256 paidFee = _registerFee(); // reverts on invalid fee
        (tokenId) = IMembership(collection).mintTo(recipient);
        require(tokenId > 0, "MINT_FAILED");
        emit Mint(collection, recipient, paidFee);
    }
}
