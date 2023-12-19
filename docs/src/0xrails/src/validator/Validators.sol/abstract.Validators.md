# Validators
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/validator/Validators.sol)

**Inherits:**
[IValidators](/src/validator/interface/IValidators.sol/interface.IValidators.md)


## Functions
### isValidator

*View function to check whether given address has been added as validator*


```solidity
function isValidator(address validator) public view virtual returns (bool);
```

### getAllValidators

*View function to retrieve all validators from storage*


```solidity
function getAllValidators() public view returns (address[] memory validators);
```

### addValidator

*Function to add the address of a Validator module to storage*


```solidity
function addValidator(address validator) external;
```

### removeValidator

*Function to remove the address of a Validator module from storage*


```solidity
function removeValidator(address validator) external;
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


### _addValidator


```solidity
function _addValidator(address validator) internal;
```

### _removeValidator


```solidity
function _removeValidator(address validator) internal;
```

### _checkCanUpdateValidators

*Function to be implemented with desired access control*


```solidity
function _checkCanUpdateValidators() internal virtual;
```

