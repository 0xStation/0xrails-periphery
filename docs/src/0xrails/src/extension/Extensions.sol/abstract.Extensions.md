# Extensions
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/Extensions.sol)

**Inherits:**
[IExtensions](/src/extension/interface/IExtensions.sol/interface.IExtensions.md)

This abstract contract provides functionality for extending function selectors using external contracts.


## Functions
### fallback

*Fallback function to delegate calls to extension contracts.*


```solidity
fallback(bytes calldata) external payable virtual returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|'' The return data from using delegatecall on the extension contract.|


### receive


```solidity
receive() external payable virtual;
```

### hasExtended

*Function to check whether the given selector is mapped to an extension contract*


```solidity
function hasExtended(bytes4 selector) public view virtual override returns (bool);
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
function extensionOf(bytes4 selector) public view virtual returns (address implementation);
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
function getAllExtensions() public view virtual returns (Extension[] memory extensions);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`extensions`|`Extension[]`|An array containing information about all registered extensions.|


### supportsInterface

*Function to implement ERC-165 compliance*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


### setExtension

*Function to set an extension contract for a given selector.*


```solidity
function setExtension(bytes4 selector, address implementation) public virtual canUpdateExtensions;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector for which to add an extension contract.|
|`implementation`|`address`|The extension contract address containing code to extend a selector|


### removeExtension

*Function to remove an extension for a given selector.*


```solidity
function removeExtension(bytes4 selector) public virtual canUpdateExtensions;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector for which to remove its extension contract.|


### _setExtension


```solidity
function _setExtension(bytes4 selector, address implementation) internal;
```

### _removeExtension


```solidity
function _removeExtension(bytes4 selector) internal;
```

### canUpdateExtensions


```solidity
modifier canUpdateExtensions();
```

### _checkCanUpdateExtensions

Should revert upon failure.

*Function to check if caller possesses sufficient permission to set extensions*


```solidity
function _checkCanUpdateExtensions() internal virtual;
```

