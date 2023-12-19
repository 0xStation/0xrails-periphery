# Validator

GroupOS has developed a modular validation schema to be used alongside the 0xRails permissioning system for maximum flexibility. The schema provides a convenient and modular way to authorize permissioned private keys, for example to validate ERC1271 smart contract signatures, ERC4337 user operations, or tokenbound account owners.

Importantly, validator contracts do not enforce the GroupOS validation schema, which requires a prepended validator flag, validator address, and signer address. The default 65-byte ECDSA signatures which are ubiquitous onchain are supported in full by default- the modular validation schema is **opt-in**.

## Usage Overview

To use the GroupOS modular validation schema, signatures provided in top level calls to an Account contract need only prepend an additional 32-byte word packed with the GroupOS `VALIDATOR_FLAG` and the address of the target validator. The details of this process are discussed in depth at the bottom of this document with code examples.

In addition, all existing validation contracts adhering to the GroupOS modular validation schema expect incoming signatures to contain a signer address prepended to the standard ECDSA "nested" signature. While this is not a required part of the spec, it currently holds true for both existing validators. This means that after the prepended validator flag + target validator address, signatures should also follow this format:

```abi.encodePacked(address signer, bytes memory ecdsaSignature)```

### CallPermitValidator

The `CallPermitValidator` module restricts valid signatures to signer addresses that have been granted the `CALL_PERMIT`` permission in the calling Accounts contract.

### OnlyOwnerValidator

The `OnlyOwnerValidator` module restricts valid signatures to the owner of the calling Accounts contract only.

## How it works

The `VALIDATOR_FLAG` is a constant declared in Account.sol and is used to signal to Account contracts whether the GroupOS modular validation is being used. This value is as follows:

```0xf88284b100000000```

Modular validation contracts check the first 8 bytes of provided signatures for this flag. If the flag is found in the first 8 bytes, the packed address of the target validator is extracted, the prepended 32-byte word (which contained the flag and the validator address) is discarded, and the remaining bytes are forwarded to the extracted validator address.

#### Constructing a valid modular validation signature

Let's construct a valid modular validation signature to demonstrate and inform developers how to use this 0xRails feature. First, we start with the prepended 32-byte word by packing the `VALIDATOR_FLAG` with the address of the target validator, in this case the `CallPermitValidator`

```solidity
// pack 32-byte word using `VALIDATOR_FLAG` bitwise OR'ed against target validator address
bytes32 validatorData = bytes32(0xf88284b100000000) | bytes32(uint256(uint160(address(callPermitValidator))));
```

Once we've constructed the prepended word to signal usage of the validation schema and provide a target validator, we also need to check whether the target validator expects any other prepended data. Currently, all GroupOS validators also require a prepended signer address, so let's add that to the ECDSA signature:

```solidity
// using `abi.encodePacked()`, pack `validatorData` and `signer` address with a standard 65-byte ECDSA signature
bytes memory formattedSig = abi.encodePacked(validatorData, signer, ecdsaSignature);
```

Great! We've constructed a valid signature that complies with the GroupOS schema. Using a CallPermitValidator address of `0x5615deb798bb3e4dfa0139dfa1b3d433cc23b72f`, and a signer address of `0xacbbb44523ee8581536434b182f775878d2889ac` here's what our signature might look like:

```solidity
// `formattedSig` comprises following calldata, concatenated:
bytes32 validatorData = bytes32(0xf88284b100000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f);
address signer = address(0xacbbb44523ee8581536434b182f775878d2889ac);
bytes memory ecdsaSignature = hex'0836d9f518d3f3261d7838324bf6c9c5916ae6eb7ee5c9b34c899e8286bac2537b4283b2912f406aa54e7d744276ebdc6d3d8c6969c6f7c0ef134c0c877f1c8f1b';

bytes memory formattedSig = hex'f88284b100000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72facbbb44523ee8581536434b182f775878d2889ac0836d9f518d3f3261d7838324bf6c9c5916ae6eb7ee5c9b34c899e8286bac2537b4283b2912f406aa54e7d744276ebdc6d3d8c6969c6f7c0ef134c0c877f1c8f1b';
```

This value for `formattedSig` would return true for any 0xRails Account's `ERC1271::isValidSignature()` and `ERC4337::validateUserOp()` functions, provided the signer address has been granted the `CALL_PERMIT` permission on the Account contract.
