# TokenMetadataStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/TokenMetadata/TokenMetadataStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x4f2e116bc9c7d925ed26e4ecc4178db33477c50c415adbd68f1ed8f0d8dace00;
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
    string name;
    string symbol;
}
```

