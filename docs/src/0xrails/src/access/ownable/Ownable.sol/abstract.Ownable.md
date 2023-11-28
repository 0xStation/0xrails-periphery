# Ownable
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/ownable/Ownable.sol)

**Inherits:**
[IOwnable](/src/access/ownable/interface/IOwnable.sol/interface.IOwnable.md)

*This contract provides access control by defining an owner address,
which can be updated through a two-step pending acceptance system or even revoked if desired.*


## Functions
### owner

*Function to return the address of the current owner*


```solidity
function owner() public view virtual returns (address);
```

### pendingOwner

*Function to return the address of the pending owner, in queued state*


```solidity
function pendingOwner() public view virtual returns (address);
```

### transferOwnership

*Function to commence ownership transfer by setting `newOwner` as pending*


```solidity
function transferOwnership(address newOwner) public virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`|The intended new owner to be set as pending, awaiting acceptance|


### acceptOwnership

*Function to accept an offer of ownership, intended to be called
only by the address that is currently set as `pendingOwner`*


```solidity
function acceptOwnership() public virtual;
```

### _transferOwnership


```solidity
function _transferOwnership(address newOwner) internal virtual;
```

### _startOwnershipTransfer


```solidity
function _startOwnershipTransfer(address newOwner) internal virtual;
```

### _acceptOwnership


```solidity
function _acceptOwnership() internal virtual;
```

### onlyOwner


```solidity
modifier onlyOwner();
```

### _checkOwner


```solidity
function _checkOwner() internal view virtual;
```

