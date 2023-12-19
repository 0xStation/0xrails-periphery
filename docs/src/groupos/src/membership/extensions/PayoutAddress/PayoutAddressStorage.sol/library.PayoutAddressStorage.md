# PayoutAddressStorage
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/PayoutAddress/PayoutAddressStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x6f6b6396a67f685820b27036440227e08d5018166d641c2de98d9ec56a7a9200;
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
    address payoutAddress;
}
```

