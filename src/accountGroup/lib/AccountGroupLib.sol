// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC6551AccountLib} from "./ERC6551AccountLib.sol";

library AccountGroupLib {
    function accountParams(address account) internal view returns (address accountGroup, uint64 subgroupId, uint32 index) {
        uint256 params = ERC6551AccountLib.salt(account);
        index = uint32(params);
        subgroupId = uint64(params >> 32);
        accountGroup = address(uint160(params >> 96));
    }
}
