# IPaymaster
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC4337/interface/IPaymaster.sol)

**Author:**
Original EIP-4337 Spec Authors: https://eips.ethereum.org/EIPS/eip-4337

*Interface contract taken from the EIP-4337 spec,
used to define requirements of a ERC-4337 Paymaster contract*


## Functions
### validatePaymasterUserOp


```solidity
function validatePaymasterUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 maxCost)
    external
    returns (bytes memory context, uint256 validationData);
```

### postOp


```solidity
function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external;
```

## Enums
### PostOpMode

```solidity
enum PostOpMode {
    opSucceeded,
    opReverted,
    postOpReverted
}
```

