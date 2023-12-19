# ExtensionBeaconFollower
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/beacon/ExtensionBeaconFollower.sol)

**Inherits:**
[Extensions](/src/extension/Extensions.sol/abstract.Extensions.md), [IExtensionBeaconFollower](/src/extension/examples/beacon/IExtensionBeacon.sol/interface.IExtensionBeaconFollower.md)


## State Variables
### extensionBeacon

```solidity
TVBF.TimeVersionedBeacon internal extensionBeacon;
```


## Functions
### extensionOf

*Function to get the extension contract address extending a specific func selector.*


```solidity
function extensionOf(bytes4 selector) public view override returns (address implementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector to query for its extension.|


### getAllExtensions

*Function to get an array of all registered extension contracts.*


```solidity
function getAllExtensions() public view override returns (Extension[] memory extensions);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`extensions`|`Extension[]`|An array containing information about all registered extensions.|


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


### removeExtensionBeacon

*Function to remove the extension beacon.*


```solidity
function removeExtensionBeacon() public virtual canUpdateExtensions;
```

### refreshExtensionBeacon

*Function to refresh the extension beacon.*


```solidity
function refreshExtensionBeacon(uint40 lastValidUpdatedAt) public virtual canUpdateExtensions;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lastValidUpdatedAt`|`uint40`|The uint40 timestamp to be set as valid|


### updateExtensionBeacon

*Function to update the extension beacon.*


```solidity
function updateExtensionBeacon(address implementation, uint40 lastValidUpdatedAt) public virtual canUpdateExtensions;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|The address to set as new extension beacon|
|`lastValidUpdatedAt`|`uint40`|The uint40 timestamp to be set as valid|


