# IValidators
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/validator/interface/IValidators.sol)


## Functions
### isValidator

*View function to check whether given address has been added as validator*


```solidity
function isValidator(address validator) external view returns (bool);
```

### getAllValidators

*View function to retrieve all validators from storage*


```solidity
function getAllValidators() external view returns (address[] memory validators);
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

## Events
### ValidatorAdded

```solidity
event ValidatorAdded(address indexed validator);
```

### ValidatorRemoved

```solidity
event ValidatorRemoved(address indexed validator);
```

## Errors
### NotEntryPoint

```solidity
error NotEntryPoint(address caller);
```

### ValidatorAlreadyExists

```solidity
error ValidatorAlreadyExists(address validator);
```

### ValidatorDoesNotExist

```solidity
error ValidatorDoesNotExist(address validator);
```

