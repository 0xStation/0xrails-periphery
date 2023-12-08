# PermissionsStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/permissions/PermissionsStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x9c5c344d590e19b509d94e6539bcccae12bdf46ca0b9e14840beae558bd13e00;
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

### _packKey


```solidity
function _packKey(bytes8 operation, address account) internal pure returns (uint256);
```

### _unpackKey


```solidity
function _unpackKey(uint256 key) internal pure returns (bytes8 operation, address account);
```

### _hashOperation


```solidity
function _hashOperation(string memory name) internal pure returns (bytes8);
```

## Structs
### Layout

```solidity
struct Layout {
    uint256[] _permissionKeys;
    mapping(uint256 => PermissionData) _permissions;
}
```

### PermissionData

```solidity
struct PermissionData {
    uint24 index;
    uint40 updatedAt;
    bool exists;
}
```

