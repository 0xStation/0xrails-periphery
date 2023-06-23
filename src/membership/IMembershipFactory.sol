// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IMembershipFactory {
    /// @notice create a new Membership preset
    function addPreset(bytes32, bytes[] calldata) external;
}
