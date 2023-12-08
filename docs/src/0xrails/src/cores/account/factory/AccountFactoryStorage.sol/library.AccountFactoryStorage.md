# AccountFactoryStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/factory/AccountFactoryStorage.sol)

**Author:**
👦🏻👦🏻.eth

*This library uses ERC7201 namespace storage
to provide a collision-resistant ledger of current account implementations*


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x9cefdb8cee5533676925ff2338aa35f7efbe2e62f58973799008a6274c385700;
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
    address accountImpl;
}
```

