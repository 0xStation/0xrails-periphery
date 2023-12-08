# IAccountGroup
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/interface/IAccountGroup.sol)


## Functions
### initialize


```solidity
function initialize(address owner) external;
```

### getDefaultAccountInitializer


```solidity
function getDefaultAccountInitializer() external view returns (address);
```

### setDefaultAccountInitializer


```solidity
function setDefaultAccountInitializer(address initializer) external;
```

### setAccountInitializer


```solidity
function setAccountInitializer(uint64 subgroupId, address initializer) external;
```

### getDefaultAccountImplementation


```solidity
function getDefaultAccountImplementation() external view returns (address);
```

### setDefaultAccountImplementation


```solidity
function setDefaultAccountImplementation(address implementation) external;
```

## Events
### DefaultInitializerUpdated

```solidity
event DefaultInitializerUpdated(address indexed initializer);
```

### SubgroupInitializerUpdated

```solidity
event SubgroupInitializerUpdated(uint64 indexed subgroupId, address indexed initializer);
```

### DefaultAccountImplementationUpdated

```solidity
event DefaultAccountImplementationUpdated(address indexed implementation);
```

## Errors
### UpgradeRestricted

```solidity
error UpgradeRestricted(address sender, address account, address implementation);
```

