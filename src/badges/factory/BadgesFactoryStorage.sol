// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library BadgesFactoryStorage {
    bytes32 internal constant SLOT = keccak256(abi.encode(uint256(keccak256("groupos.BadgesFactory")) - 1));

    struct Layout {
        address badgesImpl;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
