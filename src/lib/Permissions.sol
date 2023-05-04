// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @notice Multi-role system managed by a singular owner with enums and bitmap packing
/// @dev inspired by OZ's AccessControl
/// TODO: add supportsInterface compatibility
contract Permissions is Ownable {
    enum Operation {
        MINT,
        BURN
    }

    event PermissionGranted(address indexed account, Operation indexed operation);
    event PermissionRevoked(address indexed account, Operation indexed operation);

    // accounts => 256 auth'd operations, each represented by their own bit
    mapping(address => bytes32) internal permissions;

    // check if sender is owner or has the permission for the operation
    modifier permitted(Operation operation) {
        require(owner() == msg.sender || hasPermission(msg.sender, operation), "NOT_PERMITTED");
        _;
    }

    function hasPermission(address account, Operation operation) public view virtual returns (bool) {
        return permissions[account] & _operationBit(operation) != 0;
    }

    function grantPermission(address account, Operation operation) external onlyOwner {
        _grant(account, operation);
    }

    function revokePermission(address account, Operation operation) external onlyOwner {
        _revoke(account, operation);
    }

    function _grant(address account, Operation operation) internal {
        require(account != address(0), "ZERO_ADDRESS");
        // bitwise OR with 1 bitshifted `operation` positions left
        // result: `operation` index value = 1
        permissions[account] |= _operationBit(operation);

        emit PermissionGranted(account, operation);
    }

    function _revoke(address account, Operation operation) internal {
        require(account != address(0), "ZERO_ADDRESS");
        // bitwise AND with NOT(1 bitshifted `operation` positions left)
        // result: `operation` index value = 0
        permissions[account] &= ~_operationBit(operation);

        emit PermissionRevoked(account, operation);
    }

    function _operationBit(Operation operation) internal pure returns (bytes32) {
        return bytes32(1 << uint8(operation));
    }
}
