# IPermissions
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/permissions/interface/IPermissions.sol)


## Functions
### hashOperation

*Function to hash an operation's `name` and typecast it to 8-bytes*


```solidity
function hashOperation(string memory name) external view returns (bytes8);
```

### hasPermission

*Function to check that an address retains the permission for an operation*


```solidity
function hasPermission(bytes8 operation, address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|An 8-byte value derived by hashing the operation name and typecasting to bytes8|
|`account`|`address`|The address to query against storage for permission|


### getAllPermissions

*Function to get an array of all existing Permission structs.*


```solidity
function getAllPermissions() external view returns (Permission[] memory permissions);
```

### addPermission

*Function to add permission for an address to carry out an operation*


```solidity
function addPermission(bytes8 operation, address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation to permit|
|`account`|`address`|The account address to be granted permission for the operation|


### removePermission

*Function to remove permission for an address to carry out an operation*


```solidity
function removePermission(bytes8 operation, address account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation to restrict|
|`account`|`address`|The account address whose permission to remove|


### checkPermission

*Function to provide reverts when checks for `hasPermission()` fails*


```solidity
function checkPermission(bytes8 operation, address account) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation to check|
|`account`|`address`|The account address whose permission to check|


## Events
### PermissionAdded

```solidity
event PermissionAdded(bytes8 indexed operation, address indexed account);
```

### PermissionRemoved

```solidity
event PermissionRemoved(bytes8 indexed operation, address indexed account);
```

## Errors
### PermissionAlreadyExists

```solidity
error PermissionAlreadyExists(bytes8 operation, address account);
```

### PermissionDoesNotExist

```solidity
error PermissionDoesNotExist(bytes8 operation, address account);
```

## Structs
### Permission

```solidity
struct Permission {
    bytes8 operation;
    address account;
    uint40 updatedAt;
}
```

