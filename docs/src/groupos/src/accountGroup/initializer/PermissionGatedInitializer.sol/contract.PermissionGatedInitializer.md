# PermissionGatedInitializer
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/initializer/PermissionGatedInitializer.sol)

**Inherits:**
AccountInitializer

Verify sender has INITIALIZE_ACCOUNT permission


## Functions
### _authenticateInitialization

*delegatecall'ed by 6551 Account*


```solidity
function _authenticateInitialization(address, bytes memory initData) internal view override returns (bytes memory);
```

