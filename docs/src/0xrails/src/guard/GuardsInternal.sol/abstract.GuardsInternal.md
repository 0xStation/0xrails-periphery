# GuardsInternal
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/guard/GuardsInternal.sol)

**Inherits:**
[IGuards](/src/guard/interface/IGuards.sol/interface.IGuards.md)


## Functions
### checkGuardBefore

*Perform checks before executing a specific operation and return guard information.*


```solidity
function checkGuardBefore(bytes8 operation, bytes memory data)
    public
    view
    returns (address guard, bytes memory checkBeforeData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation identifier to check.|
|`data`|`bytes`|Additional data associated with the operation.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`guard`|`address`|The address of the guard contract responsible for the operation.|
|`checkBeforeData`|`bytes`|Additional data from the guard contract's checkBefore function.|


### checkGuardAfter

*Perform checks after executing an operation.*


```solidity
function checkGuardAfter(address guard, bytes memory checkBeforeData, bytes memory executionData) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`guard`|`address`|The address of the guard contract responsible for the operation.|
|`checkBeforeData`|`bytes`|Additional data obtained from the guard's checkBefore function.|
|`executionData`|`bytes`|The execution data associated with the operation.|


### guardOf

*Get the guard contract address responsible for a specific operation.*


```solidity
function guardOf(bytes8 operation) public view returns (address implementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation identifier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|The address of the guard contract for the operation.|


### getAllGuards

*Get an array of all registered guard contracts.*


```solidity
function getAllGuards() public view virtual returns (Guard[] memory guards);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`guards`|`Guard[]`|Guards An array containing information about all registered guard contracts.|


### _setGuard


```solidity
function _setGuard(bytes8 operation, address implementation) internal;
```

### _removeGuard


```solidity
function _removeGuard(bytes8 operation) internal;
```

