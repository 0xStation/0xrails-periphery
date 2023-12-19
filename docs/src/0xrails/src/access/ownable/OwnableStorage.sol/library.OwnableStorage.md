# OwnableStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/ownable/OwnableStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0xf3c239b52c8c2d34fdf8aafa68bc754708c9395be7e6fed11d1fb0f4f4168c00;
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Structs
### Layout

```solidity
struct Layout {
    address owner;
    address pendingOwner;
}
```

