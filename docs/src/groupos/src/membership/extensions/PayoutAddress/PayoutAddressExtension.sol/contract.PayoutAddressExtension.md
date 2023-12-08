# PayoutAddressExtension
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol)

**Inherits:**
[PayoutAddress](/src/membership/extensions/PayoutAddress/PayoutAddress.sol/abstract.PayoutAddress.md), Extension


## Functions
### getAllSelectors


```solidity
function getAllSelectors() public pure override returns (bytes4[] memory selectors);
```

### signatureOf


```solidity
function signatureOf(bytes4 selector) public pure override returns (string memory);
```

