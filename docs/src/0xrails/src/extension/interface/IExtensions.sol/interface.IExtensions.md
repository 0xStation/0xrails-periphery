# IExtensions
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/interface/IExtensions.sol)


## Functions
### hasExtended

*Function to check whether the given selector is mapped to an extension contract*


```solidity
function hasExtended(bytes4 selector) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|'' Boolean value identifying if the given selector is extended or not|


### extensionOf

*Function to get the extension contract address extending a specific func selector.*


```solidity
function extensionOf(bytes4 selector) external view returns (address implementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector to query for its extension.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|The address of the extension contract for the function.|


### getAllExtensions

*Function to get an array of all registered extension contracts.*


```solidity
function getAllExtensions() external view returns (Extension[] memory extensions);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`extensions`|`Extension[]`|An array containing information about all registered extensions.|


### setExtension

*Function to set a extension contract for a specific function selector.*


```solidity
function setExtension(bytes4 selector, address implementation) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector for which to set an extension contract.|
|`implementation`|`address`|The address of the extension contract to map to a function.|


### removeExtension

*Function to remove the extension contract for a function.*


```solidity
function removeExtension(bytes4 selector) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector for which to remove its extension.|


## Events
### ExtensionUpdated

```solidity
event ExtensionUpdated(bytes4 indexed selector, address indexed oldExtension, address indexed newExtension);
```

## Errors
### ExtensionDoesNotExist

```solidity
error ExtensionDoesNotExist(bytes4 selector);
```

### ExtensionAlreadyExists

```solidity
error ExtensionAlreadyExists(bytes4 selector);
```

### ExtensionUnchanged

```solidity
error ExtensionUnchanged(bytes4 selector, address oldImplementation, address newImplementation);
```

## Structs
### Extension

```solidity
struct Extension {
    bytes4 selector;
    address implementation;
    uint40 updatedAt;
    string signature;
}
```

