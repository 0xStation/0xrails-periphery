# Permissions
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/permissions/Permissions.sol)

**Inherits:**
[IPermissions](/src/access/permissions/interface/IPermissions.sol/interface.IPermissions.md)


## Functions
### checkPermission

*Function to provide reverts when checks for `hasPermission()` fails*


```solidity
function checkPermission(bytes8 operation, address account) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation to check|
|`account`|`address`|The account address whose permission to check|


### hasPermission

*Function to check that an address retains the permission for an operation*


```solidity
function hasPermission(bytes8 operation, address account) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|An 8-byte value derived by hashing the operation name and typecasting to bytes8|
|`account`|`address`|The address to query against storage for permission|


### getAllPermissions

*Function to get an array of all existing Permission structs.*


```solidity
function getAllPermissions() public view returns (Permission[] memory permissions);
```

### hashOperation

*Function to hash an operation's `name` and typecast it to 8-bytes*


```solidity
function hashOperation(string memory name) public pure returns (bytes8);
```

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


### addPermission

*Function to add permission for an address to carry out an operation*


```solidity
function addPermission(bytes8 operation, address account) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation to permit|
|`account`|`address`|The account address to be granted permission for the operation|


### removePermission

*Function to remove permission for an address to carry out an operation*


```solidity
function removePermission(bytes8 operation, address account) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation to restrict|
|`account`|`address`|The account address whose permission to remove|


### _addPermission


```solidity
function _addPermission(bytes8 operation, address account) internal;
```

### _removePermission


```solidity
function _removePermission(bytes8 operation, address account) internal;
```

### onlyPermission


```solidity
modifier onlyPermission(bytes8 operation);
```

### _checkPermission

*Function to ensure `account` has permission to carry out `operation`*


```solidity
function _checkPermission(bytes8 operation, address account) internal view;
```

### _checkCanUpdatePermissions

*Function to implement access control restricting setter functions*


```solidity
function _checkCanUpdatePermissions() internal virtual;
```

