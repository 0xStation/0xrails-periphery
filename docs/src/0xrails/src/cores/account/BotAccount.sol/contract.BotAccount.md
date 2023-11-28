# BotAccount
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/BotAccount.sol)

**Inherits:**
[AccountRails](/src/cores/account/AccountRails.sol/abstract.AccountRails.md), [Ownable](/src/access/ownable/Ownable.sol/abstract.Ownable.md), [Initializable](/src/lib/initializable/Initializable.sol/abstract.Initializable.md)

**Author:**
👦🏻👦🏻.eth

*This contract provides a single hub for managing and verifying signatures
created either using the GroupOS modular validation schema or default signatures.
ERC1271 and ERC4337 are supported, in combination with the 0xRails permissions system*


## Functions
### constructor


```solidity
constructor(address _entryPointAddress) Account(_entryPointAddress) Initializable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_entryPointAddress`|`address`|The contract address for this chain's ERC-4337 EntryPoint contract|


### initialize

Permission to execute `Call::call()` on this contract is granted to the EntryPoint in Accounts


```solidity
function initialize(address _owner, address _callPermitValidator, address[] memory _trustedCallers)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The owner address of this contract which retains call permissions management rights|
|`_callPermitValidator`|`address`|The initial CallPermitValidator address to handle modular sig verification|
|`_trustedCallers`|`address[]`|The initial trusted caller addresses to support as recognized signers|


### _defaultValidateUserOp

*When evaluating signatures that don't contain the `VALIDATOR_FLAG`, authenticate only the owner*


```solidity
function _defaultValidateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256)
    internal
    view
    virtual
    override
    returns (bool);
```

### _defaultIsValidSignature

*When evaluating signatures that don't contain the `VALIDATOR_FLAG`, authenticate only the owner*


```solidity
function _defaultIsValidSignature(bytes32 hash, bytes memory signature) internal view virtual override returns (bool);
```

### owner

This function must be overridden by contracts inheriting `Account` to delineate
the type of Account: `Bot`, `Member`, or `Group`

*Owner stored explicitly using OwnableStorage's ERC7201 namespace*


```solidity
function owner() public view virtual override(Access, Ownable) returns (address);
```

### withdrawFromEntryPoint

*Function to withdraw funds using the EntryPoint's `withdrawTo()` function*


```solidity
function withdrawFromEntryPoint(address payable recipient, uint256 amount) public virtual override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address payable`|The address to receive from the EntryPoint balance|
|`amount`|`uint256`|The amount of funds to withdraw from the EntryPoint|


### _checkCanUpdateExtensions


```solidity
function _checkCanUpdateExtensions() internal view override;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address) internal view override;
```

