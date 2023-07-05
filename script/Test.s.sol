// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/lib/renderer/Renderer.sol";
import {Batch} from "src/lib/Batch.sol";
import {Membership} from "src/membership/Membership.sol";

contract Test is Script {
    bytes32 private constant GRANT_TYPE_HASH =
        keccak256("Grant(address sender,uint48 expiration,uint256 nonce,bytes data)");
    bytes32 private constant DOMAIN_TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        require(
            GRANT_TYPE_HASH == 0x19e3b6d0efd75ce8f4d43297a4bfdfcff5ced60bb9955c042552dc6546dfc63d, "TYPEHASH_MISMATCH"
        );

        vm.stopBroadcast();
    }
}
