// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "../membership/IMembership.sol";
import {FeeModule} from "../lib/module/FeeModule.sol";

contract PublicFreeMintModule is FeeModule {
    event Mint(address indexed collection, address indexed recipient, uint256 fee);

    constructor(address newOwner) FeeModule(newOwner) {}

    function mint(address collection) external payable {
        _mint(collection, msg.sender);
    }

    function mintTo(address collection, address recipient) external payable {
        _mint(collection, recipient);
    }

    function _mint(address collection, address recipient) internal {
        uint256 paidFee = _registerFee(); // reverts on invalid fee
        (uint256 tokenId) = IMembership(collection).mintTo(recipient);
        require(tokenId > 0, "MINT_FAILED");
        emit Purchase(collection, recipient, price, paidFee);
    }
}
