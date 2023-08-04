// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Owner} from "mage/access/owner/Owner.sol";
import {Initializer} from "mage/lib/Initializer/Initializer.sol";
import {IMageToken} from "mage/cores/IMageToken.sol";

import {IMembershipFactory} from "./interface/IMembershipFactory.sol";

contract MembershipFactory is Initializer, Owner, UUPSUpgradeable, IMembershipFactory {
    address public membershipImpl;

    function initialize(address membershipImpl_, address owner_) external initializer {
        membershipImpl = membershipImpl_;
        _transferOwnership(owner_);
    }

    function updateMembershipImpl(address newImpl) external onlyOwner {
        membershipImpl = newImpl;
        emit MembershipUpdated(newImpl);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address membership)
    {
        bytes memory initialization =
            abi.encodeWithSelector(IMageToken(membershipImpl).initialize.selector, owner, name, symbol, initData);
        membership = address(new ERC1967Proxy(membershipImpl, initialization));

        emit MembershipCreated(membership);
    }

    // non-payable fallback to reject accidental inbound ETH transfer
    fallback() external {}
}
