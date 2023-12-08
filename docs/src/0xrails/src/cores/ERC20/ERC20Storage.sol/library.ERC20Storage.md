# ERC20Storage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC20/ERC20Storage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0xcc1a765547cda1929f5295f82a3b2c17f80d5562fb7a939737a5cdd530117500;
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
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
}
```

