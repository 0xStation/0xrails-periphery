# ExtensionBeacon
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/beacon/ExtensionBeacon.sol)

**Inherits:**
[Extensions](/src/extension/Extensions.sol/abstract.Extensions.md), [IExtensionBeacon](/src/extension/examples/beacon/IExtensionBeacon.sol/interface.IExtensionBeacon.md)


## Functions
### extensionOf

*Function to get the extension contract address extending a specific func selector.*


```solidity
function extensionOf(bytes4 selector, uint40 lastValidUpdatedAt)
    public
    view
    override
    returns (address implementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector to query for its extension.|
|`lastValidUpdatedAt`|`uint40`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|The extension contract address for `selector`|


### supportsInterface

*Function to implement ERC-165 compliance*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


