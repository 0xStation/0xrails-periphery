// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library PayoutAddressStorage {
    bytes32 internal constant SLOT = bytes32(uint256(keccak256("groupos.PayoutAddress")) - 1);

    struct Layout {
        address payoutAddress;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
