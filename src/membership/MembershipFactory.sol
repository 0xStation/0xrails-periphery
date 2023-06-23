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
import {EnumerableSetUpgradeable} from "openzeppelin-contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract MembershipFactory is OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable, MembershipFactoryStorageV0 {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

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
        bytes32 labelHash
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        membership = create(address(this), renderer, name, symbol);

        setupResults = _setupFromPresets(labelHash, membership);

        // transfer ownership to provided argument
        Permissions(membership).transferOwnership(owner);
    }

    /// @notice create a new Membership from presets and custom calls
    function createFromPresetsAndSetUp(
        address owner,
        address renderer,
        string memory name,
        string memory symbol,
        bytes[] calldata setupCalls,
        bytes32 labelHashHash
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        membership = create(address(this), renderer, name, symbol);

        Batch.Result[] memory batchSetupResults = Batch(membership).batch(false, setupCalls);
        Batch.Result[] memory presetSetupResults = _setupFromPresets(labelHash, membership);

        setupResults = new Batch.Result[](batchSetupResults.length + presetSetupResults.length);

        for (uint i = 0; i < batchSetupResults.length; i++) {
            setupResults[i] = batchSetupResults[i];
        }

        for (uint i = 0; i < presetSetupResults.length; i++) {
            setupResults[i + batchSetupResults.length] = presetSetupResults[i];
        }

        // transfer ownership to provided argument
        Permissions(membership).transferOwnership(owner);
    }

    /// @notice internal helper function for setting up membership from a preset
    function _setupFromPresets(bytes32 labelHash, address membership) internal returns (Batch.Result[] memory) {
        // get the set of preset calls from storage, revert if does not exist
        Preset memory p = _presetMap[labelHash];
        require(p.calls.length > 0, "Preset does not exist");
        // make non-atomic batch call, using permission as owner to do anything
        return Batch(membership).batch(false, p.calls);
    }

    /// @notice get Number of presets available
    function getNumPresets() public view returns (uint) {
        return _presetKeys.length();
    }

    /// @notice get Preset at index
    function getPresetByIdx(uint idx) public view returns (Preset memory) {
        return _presetMap[_presetKeys.at(idx)];
    }

    /// @notice create a new Membership preset
    function addPreset(bytes32 labelHash, bytes[] calldata calls) external onlyOwner {
        require(calls.length > 0, "No calls");
        require(_presetKeys.add(labelHash), "Preset label already exists");
        _presetMap[labelHash] = Preset(label, calls);
    }

    /// @notice modifies an existing Membership preset
    function modifyPreset(bytes32 labelHash, bytes[] calldata calls) external onlyOwner {
        require(calls.length > 0, "No calls");
        require(_presetKeys.contains(labelHash), "Preset does not exist");
        _presetMap[labelHash] = Preset(label, calls);
    }

    /// @notice deletes a Membership preset
    function deletePreset(bytes32 labelHash) external onlyOwner {
        require(_presetKeys.remove(labelHash), "Preset does not exist");
        delete _presetMap[labelHash];
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
