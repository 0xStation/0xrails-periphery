# AccountInitializer
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC6551AccountGroup/AccountInitializer.sol)

**Inherits:**
[IERC6551AccountInitializer](/src/lib/ERC6551AccountGroup/interface/IERC6551AccountInitializer.sol/interface.IERC6551AccountInitializer.md), ERC1967Upgrade

Reference abstract Account Initializer implementation.
Set up re-initialization prevention and modularize authentication on initialization data.


## Functions
### initializeAccount

delegatecall'ed by ERC6551 Account 1167Proxy


```solidity
function initializeAccount(address accountImpl, bytes memory initData) external payable;
```

### _authenticateInitialization

Check is account implementation is allowed, strip provided initData


```solidity
function _authenticateInitialization(address accountImpl, bytes memory initData)
    internal
    view
    virtual
    returns (bytes memory accountData);
```

## Errors
### AlreadyInitialized

```solidity
error AlreadyInitialized();
```

