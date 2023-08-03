// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Batch} from "src/lib/Batch.sol";

interface IMembership {
    function initialize(address owner, string calldata name, string calldata symbol, bytes calldata initData)
        external;
}
