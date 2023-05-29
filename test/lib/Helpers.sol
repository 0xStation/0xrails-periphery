// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Account} from "./helpers/Account.sol";
import {Permissions} from "./helpers/Permissions.sol";

abstract contract Helpers is Account, Permissions {}
