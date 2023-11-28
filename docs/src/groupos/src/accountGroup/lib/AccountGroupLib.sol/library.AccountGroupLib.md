# AccountGroupLib
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/lib/AccountGroupLib.sol)


## Functions
### accountParams


```solidity
function accountParams(address account) internal view returns (AccountParams memory);
```

### accountParams


```solidity
function accountParams() internal view returns (AccountParams memory);
```

## Structs
### AccountParams

```solidity
struct AccountParams {
    uint32 index;
    uint64 subgroupId;
    address accountGroup;
}
```

