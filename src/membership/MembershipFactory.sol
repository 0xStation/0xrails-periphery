// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "openzeppelin-contracts-upgradeable/security/PausableUpgradeable.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";

import "./IMembership.sol";
import {Batch} from "src/lib/Batch.sol";
import {IBeacon} from "openzeppelin-contracts/proxy/beacon/IBeacon.sol";
import {BeaconProxy} from "src/lib/beacon/BeaconProxy.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {MembershipFactoryStorageV0} from "./storage/MembershipFactoryStorageV0.sol";

contract MembershipFactory is OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable, MembershipFactoryStorageV0 {

    event MembershipCreated(address indexed membership);

    address public beacon;

    /// @notice initialize owner, the impl the proxies point to, and pausing
    function initialize(address _owner, address _beacon) external initializer {
        __Pausable_init();
        __Ownable_init();
        transferOwnership(_owner);

        beacon = _beacon;
    }

    /// @notice only owner can upgrade
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice create a new Membership via BeaconProxy
    function createWithBeacon(address owner, address renderer, string memory name, string memory symbol)
        public
        whenNotPaused
        returns (address membership)
    {
        bytes memory initData =
            abi.encodeWithSelector(IMembership(IBeacon(beacon).implementation()).init.selector, owner, renderer, name, symbol);
        membership = address(new BeaconProxy(beacon, initData));

        emit MembershipCreated(membership);
    }

/// @notice create a new Membership via ERC1967Proxy and a custom Implementation
    function createWithoutBeacon(
        address customImpl,
        address owner, 
        address renderer, 
        string memory name, 
        string memory symbol
    ) public whenNotPaused returns (address membership)
    {
        bytes memory initData =
            abi.encodeWithSelector(IMembership(customImpl).init.selector, owner, renderer, name, symbol);
        membership = address(new ERC1967Proxy(customImpl, initData));

        emit MembershipCreated(membership);
    }
    /// @notice create a new Membership via ERC1967Proxy and setup other parameters
    function createAndSetUp(
        address owner,
        address renderer,
        string memory name,
        string memory symbol,
        bytes[] calldata setupCalls,
        bool useBeacon,
        address customImpl
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        if (useBeacon) {
            membership = createWithBeacon(address(this), renderer, name, symbol);
        } else {
            membership = createWithoutBeacon(customImpl, address(this), renderer, name, symbol);
        }
        // make non-atomic batch call, using permission as owner to do anything
        setupResults = Batch(membership).batch(false, setupCalls);
        // transfer ownership to provided argument
        Permissions(membership).transferOwnership(owner);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // protect against accidental renouncing
    function renounceOwnership() public view override onlyOwner {
        revert("cannot renounce");
    }

    fallback() external {}
}
