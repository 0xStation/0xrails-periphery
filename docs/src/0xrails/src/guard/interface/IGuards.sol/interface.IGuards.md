# IGuards
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/guard/interface/IGuards.sol)


## Functions
### checkGuardBefore

*Perform checks before executing a specific operation and return guard information.*


```solidity
function checkGuardBefore(bytes8 operation, bytes calldata data)
    external
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
function checkGuardAfter(address guard, bytes calldata checkBeforeData, bytes calldata executionData) external view;
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
function guardOf(bytes8 operation) external view returns (address implementation);
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
function getAllGuards() external view returns (Guard[] memory Guards);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`Guards`|`Guard[]`|An array containing information about all registered guard contracts.|


### setGuard

*Set a guard contract for a specific operation.*


```solidity
function setGuard(bytes8 operation, address implementation) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation identifier for which to set the guard contract.|
|`implementation`|`address`|The address of the guard contract to set.|


### removeGuard

*Remove the guard contract for a specific operation.*


```solidity
function removeGuard(bytes8 operation) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation identifier for which to remove the guard contract.|


## Events
### GuardUpdated

```solidity
event GuardUpdated(bytes8 indexed operation, address indexed oldGuard, address indexed newGuard);
```

## Errors
### GuardDoesNotExist

```solidity
error GuardDoesNotExist(bytes8 operation);
```

### GuardUnchanged

```solidity
error GuardUnchanged(bytes8 operation, address oldImplementation, address newImplementation);
```

### GuardRejected

```solidity
error GuardRejected(bytes8 operation, address guard);
```

## Structs
### Guard

```solidity
struct Guard {
    bytes8 operation;
    address implementation;
    uint40 updatedAt;
}
```

