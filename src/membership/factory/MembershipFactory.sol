// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "0xrails/access/ownable/Ownable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";

import {IMembershipFactory} from "./IMembershipFactory.sol";
import {MembershipFactoryStorage} from "./MembershipFactoryStorage.sol";

contract MembershipFactory is Initializable, Ownable, UUPSUpgradeable, IMembershipFactory {
    /*============
        SET UP
    ============*/

    constructor() Initializable() {}

    function initialize(address membershipImpl_, address owner_) external initializer {
        _updateMembershipImpl(membershipImpl_);
        _transferOwnership(owner_);
    }

    function membershipImpl() public view returns (address) {
        return MembershipFactoryStorage.layout().membershipImpl;
    }

    function setMembershipImpl(address newImpl) external onlyOwner {
        _updateMembershipImpl(newImpl);
    }

    function _updateMembershipImpl(address newImpl) internal {
        if (newImpl == address(0)) revert InvalidImplementation();
        MembershipFactoryStorage.Layout storage layout = MembershipFactoryStorage.layout();
        layout.membershipImpl = newImpl;
        emit MembershipUpdated(newImpl);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*============
        CREATE
    ============*/

    function create(address membershipOwner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address membership)
    {
        membership = address(new ERC1967Proxy(membershipImpl(), bytes("")));
        emit MembershipCreated(membership); // put MembershipCreated before initialization events for indexer convenience
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC721Rails(membership).initialize(membershipOwner, name, symbol, initData);
    }
}
