# ValidatorsStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/validator/ValidatorsStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x501077102342bdb85f23d25bb36efd0f86b07c38e46b63bec983266db4374200;
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
    address[] _validators;
    mapping(address => ValidatorData) _validatorData;
}
```

### ValidatorData

```solidity
struct ValidatorData {
    uint24 index;
    bool exists;
}
```

