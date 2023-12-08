# IExtensionBeacon
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/beacon/IExtensionBeacon.sol)


## Functions
### extensionOf

*Function to get the extension contract address extending a specific func selector.*


```solidity
function extensionOf(bytes4 selector, uint40 updatedBefore) external view returns (address implementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector to query for its extension.|
|`updatedBefore`|`uint40`|The uint40 timestamp of update|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|The extension contract address for `selector`|


## Errors
### ExtensionUpdatedAfter

```solidity
error ExtensionUpdatedAfter(bytes4 selector, uint40 updatedAt, uint40 updateThreshold);
```

