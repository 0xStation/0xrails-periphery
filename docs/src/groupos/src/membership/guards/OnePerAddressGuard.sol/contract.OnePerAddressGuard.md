# OnePerAddressGuard
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/guards/OnePerAddressGuard.sol)

**Inherits:**
IGuard

**Author:**
symmetry (@symmtry69)

This contract serves as a guard pattern implementation, similar to that of Gnosis Safe contracts,
designed to ensure that an address can only own one ERC-721 token at a time.


## Functions
### checkBefore

*Hook to perform pre-call checks and return guard information.*


```solidity
function checkBefore(address, bytes calldata data) external view returns (bytes memory checkBeforeData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`||
|`data`|`bytes`|The data associated with the action, including relevant parameters.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`checkBeforeData`|`bytes`|Additional data to be passed to the `checkAfter` function.|


### checkAfter

*Hook to perform post-call checks.*


```solidity
function checkAfter(bytes calldata checkBeforeData, bytes calldata) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`checkBeforeData`|`bytes`|Data passed from the `checkBefore` function.|
|`<none>`|`bytes`||


## Errors
### OnePerAddress

```solidity
error OnePerAddress(address owner, uint256 balance);
```

