# IAccountFactory
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/factory/interface/IAccountFactory.sol)


## Functions
### simulateCreate2

*Function to simulate a `CREATE2` deployment using a given salt and desired AccountType*


```solidity
function simulateCreate2(bytes32 salt, bytes32 creationCodeHash) external view returns (address);
```

### setAccountImpl

*Function to set the implementation address whose logic will be used by deployed account proxies*


```solidity
function setAccountImpl(address newAccountImpl) external;
```

### getAccountImpl

*Function to get the implementation address whose logic is used by deployed account proxies*


```solidity
function getAccountImpl() external view returns (address);
```

## Events
### AccountImplUpdated

```solidity
event AccountImplUpdated(address indexed accountImpl);
```

### AccountCreated

```solidity
event AccountCreated(address indexed account);
```

## Errors
### InvalidImplementation

```solidity
error InvalidImplementation();
```

