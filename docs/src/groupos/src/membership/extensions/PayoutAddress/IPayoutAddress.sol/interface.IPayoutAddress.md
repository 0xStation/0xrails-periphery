# IPayoutAddress
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/PayoutAddress/IPayoutAddress.sol)


## Functions
### payoutAddress

*Returns the address of the current `payoutAddress` in storage*


```solidity
function payoutAddress() external view returns (address);
```

### updatePayoutAddress

*Updates the current payout address to the provided `payoutAddress`*


```solidity
function updatePayoutAddress(address payoutAddress) external;
```

### removePayoutAddress

*Removes the current payout address, replacing it with address(0x0)*


```solidity
function removePayoutAddress() external;
```

## Events
### PayoutAddressUpdated

```solidity
event PayoutAddressUpdated(address oldPayoutAddress, address newPayoutAddress);
```

## Errors
### PayoutAddressIsZero

```solidity
error PayoutAddressIsZero();
```

