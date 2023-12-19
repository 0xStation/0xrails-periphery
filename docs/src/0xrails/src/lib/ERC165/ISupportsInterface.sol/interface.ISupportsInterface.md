# ISupportsInterface
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC165/ISupportsInterface.sol)


## Functions
### supportsInterface

*Function to implement ERC-165 compliance*


```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


### addInterface

*Function to add support for a specific interface.*


```solidity
function addInterface(bytes4 interfaceId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to add support for.|


### removeInterface

*Function to remove support for a specific interface.*


```solidity
function removeInterface(bytes4 interfaceId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to remove support for.|


## Events
### InterfaceAdded

```solidity
event InterfaceAdded(bytes4 indexed interfaceId);
```

### InterfaceRemoved

```solidity
event InterfaceRemoved(bytes4 indexed interfaceId);
```

## Errors
### InterfaceAlreadyAdded

```solidity
error InterfaceAlreadyAdded(bytes4 interfaceId);
```

### InterfaceNotAdded

```solidity
error InterfaceNotAdded(bytes4 interfaceId);
```

