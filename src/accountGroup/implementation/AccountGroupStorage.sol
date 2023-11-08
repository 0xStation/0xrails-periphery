// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library AccountGroupStorage {
    bytes32 internal constant SLOT = keccak256(abi.encode(uint256(keccak256("groupos.AccountGroup")) - 1));

    /// @param defaultInitializer The default initialize controller used to configure ERC6551 accounts on deployment
    /// @param initializerOf Mapping to override the default initialize controller for a subgroupId
    /// @notice ERC6551 accounts may only upgrade to an account approved by the account group
    struct Layout {
        address defaultInitializer;
        mapping(uint64 => address) initializerOf;
        address defaultAccountImplementation;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
