# GuardsStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/guard/GuardsStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x68fdbc9be968974abe602a5cbdd43c5fd2f2d66bfde2f0188149c63e523d4d00;
```


### MAX_ADDRESS

```solidity
address internal constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

### autoReject

*Function to check for guards that have been set to the max address,
signaling automatic rejection of an operation*


```solidity
function autoReject(address guard) internal pure returns (bool);
```

### autoApprove

*Function to check for guards that have been set to the zero address,
signaling automatic approval of an operation*


```solidity
function autoApprove(address guard) internal pure returns (bool);
```

## Structs
### Layout

```solidity
struct Layout {
    bytes8[] _operations;
    mapping(bytes8 => GuardData) _guards;
}
```

### GuardData

```solidity
struct GuardData {
    uint24 index;
    uint40 updatedAt;
    address implementation;
}
```

## Enums
### CheckType

```solidity
enum CheckType {
    BEFORE,
    AFTER
}
```

