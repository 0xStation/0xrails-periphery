# PayoutAddress
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/PayoutAddress/PayoutAddress.sol)

**Inherits:**
[IPayoutAddress](/src/membership/extensions/PayoutAddress/IPayoutAddress.sol/interface.IPayoutAddress.md)

It is not to be instantiated directly, but inherited by eg. PayoutAddressExtension

*This contract provides utilities to manage collections' payout address*


## Functions
### payoutAddress

*Returns the address of the current `payoutAddress` in storage*


```solidity
function payoutAddress() public view virtual returns (address);
```

### updatePayoutAddress

*Updates the current payout address to the provided `payoutAddress`*


```solidity
function updatePayoutAddress(address newPayoutAddress) external virtual;
```

### removePayoutAddress

*Removes the current payout address, replacing it with address(0x0)*


```solidity
function removePayoutAddress() external virtual;
```

### _updatePayoutAddress


```solidity
function _updatePayoutAddress(address newPayoutAddress) internal;
```

### _checkCanUpdatePayoutAddress

This function is meant to be invoked in the context of `delegatecall`


```solidity
function _checkCanUpdatePayoutAddress() internal virtual;
```

