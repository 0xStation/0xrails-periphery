# CallPermitValidator
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/validator/CallPermitValidator.sol)

**Inherits:**
[Validator](/src/validator/Validator.sol/abstract.Validator.md)

*Validator module that restricts valid signatures to only come from addresses
that have been granted the `CALL_PERMIT` permission in the calling Accounts contract,
providing a convenient modular way to manage permissioned private keys*


## Functions
### constructor


```solidity
constructor(address _entryPointAddress) Validator(_entryPointAddress);
```

### validateUserOp

The top level call context to an `Account` implementation must prepend
an additional 32-byte word packed with the `VALIDATOR_FLAG` and this address

*Function to enable user operations and comply with `IAccount` interface defined in the EIP-4337 spec*

*This contract expects signatures in this function's call context to contain a `signer` address
prepended to the ECDSA `nestedSignature`, ie: `abi.encodePacked(address signer, bytes memory nestedSig)`*


```solidity
function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256)
    external
    virtual
    returns (uint256 validationData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`userOp`|`UserOperation`|The ERC-4337 user operation, including a `signature` to be recovered and verified|
|`userOpHash`|`bytes32`|The hash of the user operation that was signed|
|`<none>`|`uint256`||


### isValidSignature

BLS sig aggregator and timestamp expiry are not currently supported by this contract
so `bytes20(0x0)` and `bytes6(0x0)` suffice. To enable support for aggregator and timestamp expiry,
override the following params

The top level call context to an `Account` implementation must prepend
an additional 32-byte word packed with the `VALIDATOR_FLAG` and this address

*Function to enable smart contract signature verification and comply with the EIP-1271 spec*

*This example contract expects signatures in this function's call context
to contain a `signer` address prepended to the ECDSA `nestedSignature`*


```solidity
function isValidSignature(bytes32 msgHash, bytes memory signature) external view virtual returns (bytes4 magicValue);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`msgHash`|`bytes32`|The hash of the message signed|
|`signature`|`bytes`|The signature to be recovered and verified|


