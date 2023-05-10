// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @notice Multi-role system managed by a singular owner with enums and bitmap packing
/// @dev inspired by OZ's AccessControl
/// TODO: add supportsInterface compatibility
contract Permissions is Ownable {
    /// @dev to remain backwards compatible, can only extend this list
    enum Operation {
        UPGRADE, // update proxy implementation & permits
        MINT, // mint new tokens
        BURN, // burn existing tokens
        TRANSFER, // transfer existing tokens
        RENDER // render nft metadata
    }

    event Permit(address indexed account, bytes32 permissions);

    // accounts => 256 auth'd operations, each represented by their own bit
    mapping(address => bytes32) public permissions;

    // check if sender is owner or has the permission for the operation
    modifier permitted(Operation operation) {
        _checkPermit(operation);
        _;
    }

    /// @dev make internal function for modifier to reduce copied code when re-using modifier
    function _checkPermit(Operation operation) internal view {
        require(owner() == msg.sender || hasPermission(msg.sender, operation), "NOT_PERMITTED");
    }

    function hasPermission(address account, Operation operation) public view virtual returns (bool) {
        return permissions[account] & _operationBit(operation) != 0;
    }

    function permit(address account, bytes32 _permissions) external permitted(Operation.UPGRADE) {
        _permit(account, _permissions);
    }

    /// @dev setup module parameters atomically with enabling/disabling permissions
    function permitAndSetup(address account, bytes32 _permissions, bytes calldata setupData)
        external
        permitted(Operation.UPGRADE)
    {
        _permit(account, _permissions);
        (bool success,) = account.call(setupData);
        require(success, "SETUP_FAILED");
    }

    function _permit(address account, bytes32 _permissions) internal {
        permissions[account] = _permissions;
        emit Permit(account, _permissions);
    }

    function permissionsValue(Operation[] memory operations) external pure returns (bytes32 value) {
        for (uint256 i; i < operations.length; i++) {
            value |= _operationBit(operations[i]);
        }
    }

    function _operationBit(Operation operation) internal pure returns (bytes32) {
        return bytes32(1 << uint8(operation));
    }
}
