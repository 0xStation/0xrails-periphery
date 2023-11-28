# IGuard
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/guard/interface/IGuard.sol)


## Functions
### checkBefore


```solidity
function checkBefore(address operator, bytes calldata data) external view returns (bytes memory checkBeforeData);
```

### checkAfter


```solidity
function checkAfter(bytes calldata checkBeforeData, bytes calldata executionData) external view;
```

