# IEntryPoint
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC4337/interface/IEntryPoint.sol)

**Inherits:**
[IStakeManager](/src/lib/ERC4337/interface/IStakeManager.sol/interface.IStakeManager.md)

**Author:**
Original EIP-4337 Spec Authors: https://eips.ethereum.org/EIPS/eip-4337

*Interface contract taken from the EIP-4337 spec,
used to interface with each chain's ERC-4337 singleton EntryPoint contract*


## Functions
### handleOps


```solidity
function handleOps(UserOperation[] calldata ops, address payable beneficiary) external;
```

### handleAggregatedOps


```solidity
function handleAggregatedOps(UserOpsPerAggregator[] calldata opsPerAggregator, address payable beneficiary) external;
```

### simulateValidation


```solidity
function simulateValidation(UserOperation calldata userOp) external;
```

### getNonce


```solidity
function getNonce(address sender, uint192 key) external view returns (uint256 nonce);
```

## Errors
### ValidationResult

```solidity
error ValidationResult(ReturnInfo returnInfo, StakeInfo senderInfo, StakeInfo factoryInfo, StakeInfo paymasterInfo);
```

### ValidationResultWithAggregation

```solidity
error ValidationResultWithAggregation(
    ReturnInfo returnInfo,
    StakeInfo senderInfo,
    StakeInfo factoryInfo,
    StakeInfo paymasterInfo,
    AggregatorStakeInfo aggregatorInfo
);
```

## Structs
### UserOpsPerAggregator

```solidity
struct UserOpsPerAggregator {
    UserOperation[] userOps;
    IAggregator aggregator;
    bytes signature;
}
```

### ReturnInfo

```solidity
struct ReturnInfo {
    uint256 preOpGas;
    uint256 prefund;
    bool sigFailed;
    uint48 validAfter;
    uint48 validUntil;
    bytes paymasterContext;
}
```

### StakeInfo

```solidity
struct StakeInfo {
    uint256 stake;
    uint256 unstakeDelaySec;
}
```

### AggregatorStakeInfo

```solidity
struct AggregatorStakeInfo {
    address actualAggregator;
    StakeInfo stakeInfo;
}
```

