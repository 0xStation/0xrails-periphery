// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ScriptUtils {
    // global addresses
    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    address public constant turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    // address public constant stationBot = ___;

    // dev addresses
    address public constant symmetry = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public constant frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    // address public constant robriks = ___;

    // to avoid collisions of a commonly deployed contract, create a combined salt with the other arguments
    function deployERC1967Proxy(bytes32 salt, address implementation, bytes memory initCode) public returns (address proxy) {
        return address(new ERC1967Proxy{salt: keccak256(abi.encodePacked(salt, implementation, initCode))}(implementation, initCode));
    }
}