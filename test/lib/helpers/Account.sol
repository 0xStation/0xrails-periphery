// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Account as TBA} from "tokenbound/src/Account.sol";

abstract contract Account {
    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function createAccount() public returns (address) {
        return address(new TBA(address(0)));
    }
}
