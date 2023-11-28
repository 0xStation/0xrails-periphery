# IAccount
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC4337/interface/IAccount.sol)

**Author:**
Original EIP-4337 Spec Authors: https://eips.ethereum.org/EIPS/eip-4337

*Interface contract taken from the original EIP-4337 spec,
used to signify ERC-4337 compliance for smart account wallets inheriting from this contract*


## Functions
### validateUserOp


```solidity
function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
    external
    returns (uint256 validationData);
```

