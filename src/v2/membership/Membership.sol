// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {ERC721Mage} from "lib/mage/src/cores/ERC721/ERC721Mage.sol";

// todo: import beacon set and add initialization params
// todo: add supportsInterface storage for extensions
contract Membership is ERC721Mage {
    function initialize(address owner_, string calldata name_, string calldata symbol_, bytes calldata initData)
        public
        initializer
    {
        _initialize(name_, symbol_);
        if (initData.length > 0) {
            // grant sender owner to ensure they have all permissions for further initialization
            _transferOwnership(msg.sender);
            Address.functionDelegateCall(address(this), initData);
            // if sender and owner arg are different, transfer ownership to desired address
            if (msg.sender != owner_) {
                _transferOwnership(owner_);
            }
        } else {
            _transferOwnership(owner_);
        }
    }
}
