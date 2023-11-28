# Initializable
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/initializable/Initializable.sol)

**Inherits:**
[IInitializable](/src/lib/initializable/IInitializable.sol/interface.IInitializable.md)


## Functions
### constructor

This applies to all child contracts inheriting from this one and use its constructor

*Logic implementation contract disables `initialize()` from being called
to prevent privilege escalation and 'exploding kitten' attacks*


```solidity
constructor();
```

### _disableInitializers


```solidity
function _disableInitializers() internal virtual;
```

### initializer


```solidity
modifier initializer();
```

### onlyInitializing


```solidity
modifier onlyInitializing();
```

### initialized

*View function to return whether a proxy contract has been initialized.*


```solidity
function initialized() public view returns (bool);
```

