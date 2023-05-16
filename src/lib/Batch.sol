// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Batch calling mechanism on the implementing contract
/// @dev inspired by BoringBatchable: https://github.com/boringcrypto/BoringSolidity/blob/master/contracts/BoringBatchable.sol
abstract contract Batch {
    function batch(bool atomic, bytes[] calldata calls) external payable {
        uint256 len = calls.length;
        for (uint256 i = 0; i < len; i++) {
            (bool success,) = address(this).delegatecall(calls[i]);
            require(success || !atomic, "BATCH_FAIL");
        }
    }
}
