// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library PointsFactoryStorage {
    bytes32 internal constant SLOT = bytes32(uint256(keccak256("groupos.PointsFactory")) - 1);

    struct Layout {
        address pointsImpl;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
