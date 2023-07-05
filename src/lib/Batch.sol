// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Batch calling mechanism on the implementing contract
/// @dev inspired by BoringBatchable and Multicall3
abstract contract Batch {
    error BatchCallFailed(bytes data);

    struct Result {
        bool success;
        bytes returnData;
    }

    /// @notice Batch multiple calls into one transaction via self-delegatecalling
    /// @dev if this function is payable, we risk unexpected behavior and exploits
    ///      of attackers using one msg.value to credit on multiple function calls
    function batch(bytes[] calldata calls) public returns (Result[] memory results) {
        uint256 len = calls.length;
        results = new Result[](len);
        for (uint256 i = 0; i < len; i++) {
            Result memory result = results[i];
            (result.success, result.returnData) = address(this).delegatecall(calls[i]);
            if (!result.success) revert BatchCallFailed(result.returnData);
        }
    }
}
