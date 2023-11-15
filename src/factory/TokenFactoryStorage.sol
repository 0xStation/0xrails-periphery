// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library TokenFactoryStorage {
    bytes32 internal constant SLOT = keccak256(abi.encode(uint256(keccak256("groupos.TokenFactory")) - 1));

    struct Layout {
        address erc20Implementation;
        address erc721Implementation;
        address erc1155Implementation;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
