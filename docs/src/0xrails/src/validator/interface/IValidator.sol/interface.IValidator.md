# IValidator
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/validator/interface/IValidator.sol)


## Functions
### validateUserOp


```solidity
function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
    external
    returns (uint256 validationData);
```

### isValidSignature


```solidity
function isValidSignature(bytes32 userOpHash, bytes calldata signature) external view returns (bytes4);
```

