// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Multi-role system managed by a singular owner with enums and bitmap packing
/// @dev inspired by OZ's AccessControl and Solmate's Owned
/// TODO: add supportsInterface compatibility
abstract contract Permissions {
    // default value for a guard that always rejects
    address constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    /// @dev to remain backwards compatible, can only extend this list
    enum Operation {
        UPGRADE, // update proxy implementation & permits
        MINT, // mint new tokens
        BURN, // burn existing tokens
        TRANSFER, // transfer existing tokens
        RENDER // render nft metadata
    }

    /*============
        EVENTS
    ============*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event Permit(address indexed account, bytes32 permissions);
    event GuardUpdated(Operation operation, address guard);

    /*=============
        STORAGE
    =============*/

    // primary superadmin of the contract
    address public owner;
    // accounts => 256 auth'd operations, each represented by their own bit
    mapping(address => bytes32) public permissions;
    // Operation => Guard smart contract, applies additional invariant constraints per operation
    // address(0) represents no constraints, address(max) represents full constraints = not allowed
    mapping(Operation => address) internal guards;

    /*=============
        OWNABLE
    =============*/

    function transferOwnership(address newOwner) external {
        require(owner == msg.sender, "NOT_PERMITTED");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /*=================
        PERMISSIONS
    =================*/

    // check if sender is owner or has the permission for the operation
    modifier permitted(Operation operation) {
        _checkPermit(operation);
        _;
    }

    /// @dev make internal function for modifier to reduce copied code when re-using modifier
    function _checkPermit(Operation operation) internal view {
        require(hasPermission(msg.sender, operation), "NOT_PERMITTED");
    }

    function hasPermission(address account, Operation operation) public view virtual returns (bool) {
        return owner == account || permissions[account] & _operationBit(operation) != 0;
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

    /*============
        GUARDS
    ============*/

    function setGuard(Operation operation, address newGuard) public permitted(Operation.UPGRADE) {
        guards[operation] = newGuard;
        emit GuardUpdated(operation, newGuard);
    }
}
