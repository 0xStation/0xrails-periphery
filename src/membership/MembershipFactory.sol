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
        string calldata presetLabel
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        membership = create(address(this), renderer, name, symbol);

        setupResults = _setupFromPresets(presetLabel, membership);

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
        string calldata presetLabel
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        membership = create(address(this), renderer, name, symbol);

        Batch.Result[] memory batchSetupResults = Batch(membership).batch(false, setupCalls);
        Batch.Result[] memory presetSetupResults = _setupFromPresets(presetLabel, membership);

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
    function _setupFromPresets(string calldata presetLabel, address membership) internal returns (Batch.Result[] memory) {
        // get the set of preset calls from storage, revert if does not exist
        Preset memory p = getPresetBylabel(presetLabel);
        require(bytes(p.label).length > 0, "Preset does not exist");
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

    /// @notice get Preset by label
    function getPresetByLabel(string calldata label) public view returns (Preset memory) {
        return _presetMap[_getKey(label)];
}

    /// @notice create a new Membership preset
    function addPreset(string calldata label, bytes[] calldata calls) external onlyOwner {
        require(bytes(label).length > 0, "Must have label");
        bytes32 key =_getKey(label);
        require(_presetKeys.add(key), "Preset label already exists");
        _presetMap[key] = Preset(label, calls);
    }

    /// @notice modifies an existing Membership preset
    function modifyPreset(string calldata label, bytes[] calldata calls) external onlyOwner {
        bytes32 key =_getKey(label);
        require(_presetKeys.contains(key), "Preset does not exist");
        _presetMap[key] = Preset(label, calls);
    }

    /// @notice deletes a Membership preset
    function deletePreset(string calldata label) external onlyOwner {
        bytes32 key =_getKey(label);
        require(_presetKeys.remove(key), "Preset does not exist");
        delete _presetMap[key];
    }

    /// @notice convert string to bytes32
    function _getKey(string calldata label) internal pure returns (bytes32) {
        return keccak256(abi.encode(label));
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
