# SupportsInterface
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC165/SupportsInterface.sol)

**Inherits:**
[ISupportsInterface](/src/lib/ERC165/ISupportsInterface.sol/interface.ISupportsInterface.md)


## State Variables
### erc165Id
*For explicit EIP165 compliance, the interfaceId of the standard IERC165 implementation
which is derived from `bytes4(keccak256('supportsInterface(bytes4)'))`
is stored directly as a constant in order to preserve Rails's ERC7201 namespace pattern*


```solidity
bytes4 public constant erc165Id = 0x01ffc9a7;
```


## Functions
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


### addInterface

*Function to add support for a specific interface.*


```solidity
function addInterface(bytes4 interfaceId) external virtual canUpdateInterfaces;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to add support for.|


### removeInterface

*Function to remove support for a specific interface.*


```solidity
function removeInterface(bytes4 interfaceId) external virtual canUpdateInterfaces;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to remove support for.|


### _supportsInterface

*To remain EIP165 compliant, this function must not be called with `bytes4(type(uint32).max)`
Setting `0xffffffff` as true by providing it as `interfaceId` will disable support of EIP165 in child contracts*


```solidity
function _supportsInterface(bytes4 interfaceId) internal view returns (bool);
```

### _addInterface


```solidity
function _addInterface(bytes4 interfaceId) internal;
```

### _removeInterface


```solidity
function _removeInterface(bytes4 interfaceId) internal;
```

### canUpdateInterfaces


```solidity
modifier canUpdateInterfaces();
```

### _checkCanUpdateInterfaces

Should revert upon failure.

*Function to check if caller possesses sufficient permission to set interfaces*


```solidity
function _checkCanUpdateInterfaces() internal virtual;
```

