# TokenFactoryStorage
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/factory/TokenFactoryStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x64845bb1a7fed623f1c8977452fce5f130e7bb0b16e10b907dc7aaef22fcc200;
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Structs
### TokenImpl

```solidity
struct TokenImpl {
    address implementation;
    TokenStandard tokenStandard;
}
```

### Layout

```solidity
struct Layout {
    TokenImpl[] tokenImplementations;
}
```

## Enums
### TokenStandard

```solidity
enum TokenStandard {
    ERC20,
    ERC721,
    ERC1155
}
```

