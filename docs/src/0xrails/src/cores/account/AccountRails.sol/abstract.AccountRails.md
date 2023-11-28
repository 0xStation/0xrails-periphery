# AccountRails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/AccountRails.sol)

**Inherits:**
[Account](/src/cores/account/Account.sol/abstract.Account.md), [Rails](/src/Rails.sol/abstract.Rails.md), [Validators](/src/validator/Validators.sol/abstract.Validators.md), IERC1271

**Author:**
👦🏻👦🏻.eth

*This abstract contract provides scaffolding for Station's Account signature validation
ERC1271 and ERC4337 compliance in combination with Rails's Permissions system
to provide convenient and modular private key management on an infrastructural level*


## Functions
### validateUserOp

To craft the signature, string concatenation or `abi.encodePacked` *must* be used
Zero-padded data will fail. Ie: `abi.encodePacked(validatorData, signer, currentRSV)` is correct

*Function enabling EIP-4337 compliance as a smart contract wallet account*


```solidity
function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
    public
    virtual
    returns (uint256 validationData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`userOp`|`UserOperation`|The UserOperation to validate before executing|
|`userOpHash`|`bytes32`|Hash of the UserOperation data, used as signature digest|
|`missingAccountFunds`|`uint256`|Delta representing this account's missing funds in the EntryPoint contract Corresponds to minimum native currency that must be transferred to the EntryPoint to complete execution Can be 0 if this account has already deposited enough funds or if a paymaster is used|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`validationData`|`uint256`|A packed uint256 of three concatenated variables ie: `uint256(abi.encodePacked(address authorizor, uint48 validUntil, uint48 validAfter))` where `authorizer` can be one of the following: 1. A signature aggregator contract, inheriting IAggregator.sol, to use for validation 2. An exit status code `bytes20(0x01)` representing signature validation failure 3. An empty `bytes20(0x0)` representing successful signature validation|


### isValidSignature

BLS sig aggregator and timestamp expiry are not currently supported by this contract
so `bytes20(0x0)` and `bytes6(0x0)` suffice. To enable support for aggregator and timestamp expiry,
override the following params

nonce collision is managed entirely by the EntryPoint, but validation hook optionality
for child contracts is provided here as `_checkNonce()` may be overridden

To craft the signature, string concatenation or `abi.encodePacked` *must* be used
Zero-padded data will fail. Ie: `abi.encodePacked(validatorData, signer, currentRSV)` is correct

*Function to recover a signer address from the provided hash and signature
and then verify whether the recovered signer address is a recognized Turnkey*


```solidity
function isValidSignature(bytes32 hash, bytes memory signature) public view returns (bytes4 magicValue);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`hash`|`bytes32`|The 32 byte digest derived by hashing signed message data. Sadly, name is canonical in ERC1271.|
|`signature`|`bytes`|The signature to be verified via recovery. Must be prepended with validator address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`magicValue`|`bytes4`|The 4-byte value representing signature validity, as defined by EIP1271 Can be one of three values: - `this.isValidSignature.selector` indicates a valid signature - `bytes4(hex'ffffffff')` indicates a signature failure bubbled up from an external modular validator - `bytes4(0)` indicates a default signature failure, ie not using the modular `VALIDATOR_FLAG`|


### _defaultIsValidSignature

Accounts do not express opinion on whether the `signer` is encoded into `userOp.signature`,
so the OZ ECDSA library should be used rather than the SignatureChecker

*Function to recover and authenticate a signer address in the context of `isValidSignature()`,
called only on signatures that were not constructed using the modular verification flag*


```solidity
function _defaultIsValidSignature(bytes32 hash, bytes memory signature) internal view virtual returns (bool);
```

### _defaultValidateUserOp

Accounts do not express opinion on whether the `signer` is available, ie encoded into `userOp.signature`,
so the OZ ECDSA library should be used rather than the SignatureChecker

*Function to recover and authenticate a signer address in the context of `validateUserOp()`,
called only on signatures that were not constructed using the modular verification flag*


```solidity
function _defaultValidateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
    internal
    view
    virtual
    returns (bool);
```

### _checkSenderIsEntryPoint

*View function to limit callers to only the EntryPoint contract of this chain*


```solidity
function _checkSenderIsEntryPoint() internal virtual;
```

### _checkNonce

*Since nonce management and collision checks are handled entirely by the EntryPoint,
this function is left empty for contracts inheriting from this one to use EntryPoint's defaults
If sequential `UserOperation` nonce ordering is desired, override this, eg: `require(nonce < type(uint64).max)`*


```solidity
function _checkNonce() internal view virtual;
```

### _preFund

*Function to pre-fund the EntryPoint contract with delta of native currency funds required for a UserOperation
By default, this function only sends enough funds to complete the current context's UserOperation
Override if sending custom amounts > `_missingAccountFunds` (or < if reverts are preferrable)*


```solidity
function _preFund(uint256 _missingAccountFunds) internal virtual;
```

### supportsInterface

*Declare explicit ERC165 support for ERC1271 interface in addition to existing interfaces*


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(Rails, Validators, ERC1155Receiver)
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interfaceId to check for support|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


### _checkCanUpdateValidators

Can be overridden for more restrictive access if desired

*Provides control over adding and removing recognized validator contracts
only to either the owner or entities possessing `ADMIN` or `VALIDATOR` permissions*


```solidity
function _checkCanUpdateValidators() internal virtual override;
```

### _checkCanUpdatePermissions

Permission to `addPermission(Operations.CALL_PERMIT)`, which is the intended
function call to be called by the owner for adding valid signer accounts such as Turnkeys,
is restricted to only the owner

*Provides control over Turnkey addresses to the owner only*


```solidity
function _checkCanUpdatePermissions() internal virtual override;
```

### _checkCanUpdateGuards


```solidity
function _checkCanUpdateGuards() internal virtual override;
```

### _checkCanExecuteCall

Mutiny by Turnkeys is prevented by granting them only the `CALL_PERMIT` permission

*Permission to `Call::call()` via signature validation is restricted to either
the EntryPoint, the owner, or entities possessing the `CALL`or `ADMIN` permissions*


```solidity
function _checkCanExecuteCall() internal view virtual override;
```

### _checkCanUpdateInterfaces

*Provides control over ERC165 layout to addresses with `INTERFACE` permission*


```solidity
function _checkCanUpdateInterfaces() internal virtual override;
```

