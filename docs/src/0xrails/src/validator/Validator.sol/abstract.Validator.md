# Validator
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/validator/Validator.sol)

**Inherits:**
[IValidator](/src/validator/interface/IValidator.sol/interface.IValidator.md)


## State Variables
### SIG_VALIDATION_FAILED
*Error code for invalid EIP-4337 `validateUserOp()`signature*

*Error return value is abbreviated to 1 since it need not include time range*


```solidity
uint8 internal constant SIG_VALIDATION_FAILED = 1;
```


### INVALID_SIGNER
*Error code for invalid EIP-1271 signature in `isValidSignature()`*

*Nonzero to define invalid sig error, as opposed to wrong validator address error, ie: `bytes4(0)`*


```solidity
bytes4 internal constant INVALID_SIGNER = hex"ffffffff";
```


### entryPoint
*Since the EntryPoint contract uses chainid and its own address to generate request ids,
its address on this chain must be available to all ERC4337-compliant validators.*


```solidity
address public immutable entryPoint;
```


## Functions
### constructor


```solidity
constructor(address _entryPointAddress);
```

### getUserOpHash

Can also be done offchain or called directly on the EntryPoint contract as it is identical

*Convenience function to generate an EntryPoint request id for a given UserOperation.
Use this output to generate an un-typed digest for signing to comply with `eth_sign` + EIP-191*


```solidity
function getUserOpHash(UserOperation calldata userOp) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`userOp`|`UserOperation`|The 4337 UserOperation to hash. The struct's signature member is discarded.|


### _innerOpHash

*Function to compute the struct hash, used within EntryPoint's `getUserOpHash()` function*


```solidity
function _innerOpHash(UserOperation memory userOp) internal pure returns (bytes32);
```

