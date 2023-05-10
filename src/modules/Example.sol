// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../membership/IMembership.sol";

contract Example {
    function example(address membership) external {
        // 1. auth

        // 2. update any local state

        // 3. mint
        (bool success) = IMembership(membership).mintTo(msg.sender);
        require(success, "MINT_FAILED");
    }
}
