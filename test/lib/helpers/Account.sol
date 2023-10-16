// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BotAccount} from "0xrails/cores/account/BotAccount.sol";

abstract contract Account {
    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function createAccount() public returns (address) {
        return address(new BotAccount(address(0)));
    }
}
