# IInitializable
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/initializable/IInitializable.sol)


## Functions
### initialized

*View function to return whether a proxy contract has been initialized.*


```solidity
function initialized() external view returns (bool);
```

## Events
### Initialized

```solidity
event Initialized();
```

## Errors
### AlreadyInitialized

```solidity
error AlreadyInitialized();
```

### NotInitializing

```solidity
error NotInitializing();
```

### CannotInitializeWhileConstructing

```solidity
error CannotInitializeWhileConstructing();
```

