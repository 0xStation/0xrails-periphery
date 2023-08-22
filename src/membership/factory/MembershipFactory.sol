// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "mage/access/ownable/Ownable.sol";
import {Initializable} from "mage/lib/initializable/Initializable.sol";
import {IERC721Mage} from "mage/cores/ERC721/interface/IERC721Mage.sol";

import {IMembershipFactory} from "./IMembershipFactory.sol";

contract MembershipFactory is Initializable, Ownable, UUPSUpgradeable, IMembershipFactory {
    address public membershipImpl;

    // todo: disable initializer in constructor

    function initialize(address membershipImpl_, address owner_) external initializer {
        membershipImpl = membershipImpl_;
        emit MembershipUpdated(membershipImpl_);
        _transferOwnership(owner_);
    }

    function updateMembershipImpl(address newImpl) external onlyOwner {
        membershipImpl = newImpl;
        emit MembershipUpdated(newImpl);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function createMembership(address owner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address membership)
    {
        membership = address(new ERC1967Proxy(membershipImpl, bytes("")));
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC721Mage(membership).initialize(owner, name, symbol, initData);
        emit MembershipCreated(membership);
    }

    // non-payable fallback to reject accidental inbound ETH transfer
    fallback() external {}
}
