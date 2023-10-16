// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC6551AccountLib} from "erc6551/lib/ERC6551AccountLib.sol";

library AccountGroupLib {
    function accountParams(address account) internal view returns (address accountGroup, uint64 subgroupId, uint32 index) {
        // assumes salt layout of 0x{accountGroup}{subgroupId}{index}
        bytes32 params = ERC6551AccountLib.salt(account);
        index = uint32(uint256(params));
        subgroupId = uint64(uint256(params) >> 32);
        accountGroup = address(uint160(uint256(params) >> 96));
    }

    function accountParams() internal view returns (address accountGroup, uint64 subgroupId, uint32 index) {
        return accountParams(address(this));
    }
}
