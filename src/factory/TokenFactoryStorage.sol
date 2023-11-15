// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library TokenFactoryStorage {
    // `keccak256(abi.encode(uint256(keccak256("groupos.TokenFactory")) - 1)) & ~bytes32(uint256(0xff));`
    bytes32 internal constant SLOT = 0x64845bb1a7fed623f1c8977452fce5f130e7bb0b16e10b907dc7aaef22fcc200;

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
