# ERC1155Storage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC1155/ERC1155Storage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x952dbaf1612c9c8046b26f71d8522ed2497f086620534427664d0784cf404500;
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
    mapping(uint256 => mapping(address => uint256)) balances;
    mapping(address => mapping(address => bool)) operatorApprovals;
    mapping(uint256 => uint256) totalSupply;
}
```

