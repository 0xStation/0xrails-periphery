// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract MembershipFactoryStorageV0 {
    struct Preset {
        string desc;
        bytes[] calls;
    }

    address public template;
    Preset[] public presets;
}
