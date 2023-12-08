# ExtensionsStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/ExtensionsStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x24b223a3be882d5d1d257152fdb15a02ae59c6d11e58bc0c17888d15a9b15b00;
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
    bytes4[] _selectors;
    mapping(bytes4 => ExtensionData) _extensions;
}
```

### ExtensionData

```solidity
struct ExtensionData {
    uint24 index;
    uint40 updatedAt;
    address implementation;
}
```

