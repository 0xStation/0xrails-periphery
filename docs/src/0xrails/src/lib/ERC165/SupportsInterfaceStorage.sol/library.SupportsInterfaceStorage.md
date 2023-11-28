# SupportsInterfaceStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC165/SupportsInterfaceStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x95a5ecff3e5709ffcdce1ca934c4b897d39c8a95719755d12b7d1e124ce29700;
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
    mapping(bytes4 => bool) _supportsInterface;
}
```

