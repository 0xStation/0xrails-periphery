// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {EnumerableSetUpgradeable} from "openzeppelin-contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

abstract contract MembershipFactoryStorageV0 {
    struct Preset {
        string label;
        bytes[] calls;
    }

    address public template;
    EnumerableSetUpgradeable.Bytes32Set internal _presetKeys;
    mapping(bytes32 => Preset) internal _presetMap;
}
