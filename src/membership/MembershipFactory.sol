// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "openzeppelin-contracts-upgradeable/security/PausableUpgradeable.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";

import "./IMembership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {MembershipFactoryStorageV0} from "./storage/MembershipFactoryStorageV0.sol";

contract MembershipFactory is OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable, MembershipFactoryStorageV0 {

    event MembershipCreated(address indexed membership);

    /// @notice initialize owner, the impl the proxies point to, and pausing
    function initialize(address _template, address _owner) external initializer {
        __Pausable_init();
        __Ownable_init();
        transferOwnership(_owner);
        template = _template;
    }

    /// @notice only owner can upgrade
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice create a new Membership via ERC1967Proxy
    function create(address owner, address renderer, string memory name, string memory symbol)
        public
        whenNotPaused
        returns (address membership)
    {
        bytes memory initData =
            abi.encodeWithSelector(IMembership(template).init.selector, owner, renderer, name, symbol);
        membership = address(new ERC1967Proxy(template, initData));

        emit MembershipCreated(membership);
    }

    /// @notice create a new Membership via ERC1967Proxy and setup other parameters
    function createAndSetUp(
        address owner,
        address renderer,
        string memory name,
        string memory symbol,
        bytes[] calldata setupCalls
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        membership = create(address(this), renderer, name, symbol);
        // make non-atomic batch call, using permission as owner to do anything
        setupResults = Batch(membership).batch(false, setupCalls);
        // transfer ownership to provided argument
        Permissions(membership).transferOwnership(owner);
    }

    /// @notice create a new Membership from presets
    function createFromPresets(
        address owner,
        address renderer,
        string memory name,
        string memory symbol,
        uint presetIdx
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        membership = create(address(this), renderer, name, symbol);
        // get the set of preset calls from storage, revert if does not exist
        Preset storage p = presets[presetIdx];
        require(bytes(p.desc).length > 0, "Preset does not exist");
        // make non-atomic batch call, using permission as owner to do anything
        setupResults = Batch(membership).batch(false, p.calls);
        // transfer ownership to provided argument
        Permissions(membership).transferOwnership(owner);
    }

    /// @notice create a new Membership preset
    function addPreset(string calldata desc, bytes[] calldata calls) external onlyOwner {
        require(bytes(desc).length > 0, "Must have description");
        presets.push(Preset(desc, calls));
    }

    /// @notice modifies an existing Membership preset
    function modifyPreset(uint idx, string calldata desc, bytes[] calldata calls) external onlyOwner {
        require(p.length > idx, "Specified idx is invalid");
        Preset p = presets[idx];
        if (bytes(desc).length > 0) {
            p.desc = desc;
        }
        if (calls.length > 0) {
            p.calls = calls;
        }
    }

    /// @notice deletes a Membership preset
    function deletePreset(uint presetIdx) external onlyOwner {
        delete presets[presetIdx];
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
