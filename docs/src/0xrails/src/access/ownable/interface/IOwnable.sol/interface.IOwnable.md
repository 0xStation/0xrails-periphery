# IOwnable
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/ownable/interface/IOwnable.sol)


## Functions
### owner

*Function to return the address of the current owner*


```solidity
function owner() external view returns (address);
```

### pendingOwner

*Function to return the address of the pending owner, in queued state*


```solidity
function pendingOwner() external view returns (address);
```

### transferOwnership

*Function to commence ownership transfer by setting `newOwner` as pending*


```solidity
function transferOwnership(address newOwner) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`|The intended new owner to be set as pending, awaiting acceptance|


### acceptOwnership

*Function to accept an offer of ownership, intended to be called
only by the address that is currently set as `pendingOwner`*


```solidity
function acceptOwnership() external;
```

## Events
### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

### OwnershipTransferStarted

```solidity
event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
```

## Errors
### OwnerUnauthorizedAccount

```solidity
error OwnerUnauthorizedAccount(address account);
```

### OwnerInvalidOwner

```solidity
error OwnerInvalidOwner(address owner);
```

