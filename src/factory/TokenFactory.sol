// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "0xrails/access/ownable/Ownable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import {IERC20Rails} from "0xrails/cores/ERC20/interface/IERC20Rails.sol";
import {IERC1155Rails} from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {TokenFactoryStorage} from "src/factory/TokenFactoryStorage.sol";

contract TokenFactory is Initializable, Ownable, UUPSUpgradeable, ITokenFactory {
    /*============
        SET UP
    ============*/

    constructor() Initializable() {}

    /// @inheritdoc ITokenFactory
    function initialize(
        address membershipImpl_, 
        address pointsImpl_, 
        address badgesImpl_, 
        address owner_
    ) external initializer {
        _updateMembershipImpl(membershipImpl_);
        _updateBadgesImpl(badgesImpl_);
        _updatePointsImpl(pointsImpl_);
        _transferOwnership(owner_);
    }

    /*===========
        VIEWS
    ===========*/

    /// @inheritdoc ITokenFactory
    function membershipImpl() public view returns (address) {
        return TokenFactoryStorage.layout().membershipImpl;
    }

    /// @inheritdoc ITokenFactory
    function pointsImpl() public view returns (address) {
        return TokenFactoryStorage.layout().pointsImpl;
    }

    /// @inheritdoc ITokenFactory
    function badgesImpl() public view returns (address) {
        return TokenFactoryStorage.layout().badgesImpl;
    }

    /*=============
        SETTERS
    =============*/

    /// @inheritdoc ITokenFactory
    function setMembershipImpl(address newImpl) external onlyOwner {
        _updateMembershipImpl(newImpl);
    }

    /// @inheritdoc ITokenFactory
    function setPointsImpl(address newImpl) external onlyOwner {
        _updatePointsImpl(newImpl);
    }

    /// @inheritdoc ITokenFactory
    function setBadgesImpl(address newImpl) external onlyOwner {
        _updateBadgesImpl(newImpl);
    }

    /*===============
        INTERNALS
    ===============*/

    function _updateMembershipImpl(address newImpl) internal {
        if (newImpl == address(0)) revert InvalidImplementation();
        TokenFactoryStorage.Layout storage layout = TokenFactoryStorage.layout();
        layout.membershipImpl = newImpl;
        emit MembershipUpdated(newImpl);
    }    

    function _updatePointsImpl(address newImpl) internal {
        if (newImpl == address(0)) revert InvalidImplementation();
        TokenFactoryStorage.Layout storage layout = TokenFactoryStorage.layout();
        layout.pointsImpl = newImpl;
        emit PointsUpdated(newImpl);
    }

    function _updateBadgesImpl(address newImpl) internal {
        if (newImpl == address(0)) revert InvalidImplementation();
        TokenFactoryStorage.Layout storage layout = TokenFactoryStorage.layout();
        layout.badgesImpl = newImpl;
        emit BadgesUpdated(newImpl);
    }

    /*============
        CREATE
    ============*/

    /// @inheritdoc ITokenFactory
    function createMembership(address membershipOwner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address membership)
    {
        membership = address(new ERC1967Proxy(membershipImpl(), bytes("")));
        emit MembershipCreated(membership); // put MembershipCreated before initialization events for indexer convenience
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC721Rails(membership).initialize(membershipOwner, name, symbol, initData);
    }

    /// @inheritdoc ITokenFactory
    function createPoints(address owner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address points)
    {
        points = address(new ERC1967Proxy(pointsImpl(), bytes("")));
        emit PointsCreated(points); // put PointsCreated before initialization events for indexer convenience
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC20Rails(points).initialize(owner, name, symbol, initData);
    }

    /// @inheritdoc ITokenFactory
    function createBadges(address owner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address badges)
    {
        badges = address(new ERC1967Proxy(badgesImpl(), bytes("")));
        emit BadgesCreated(badges); // put BadgesCreated before initialization events for indexer convenience
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC1155Rails(badges).initialize(owner, name, symbol, initData);
    }

    /*===============
        OVERRIDES
    ===============*/

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}