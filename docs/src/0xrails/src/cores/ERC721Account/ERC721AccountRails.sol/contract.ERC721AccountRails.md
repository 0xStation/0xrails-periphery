# ERC721AccountRails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721Account/ERC721AccountRails.sol)

**Inherits:**
[AccountRails](/src/cores/account/AccountRails.sol/abstract.AccountRails.md), [ERC6551Account](/src/lib/ERC6551/ERC6551Account.sol/abstract.ERC6551Account.md), [Initializable](/src/lib/initializable/Initializable.sol/abstract.Initializable.md), [IERC721AccountRails](/src/cores/ERC721Account/interface/IERC721AccountRails.sol/interface.IERC721AccountRails.md)

An ERC-4337 Account bound to an ERC-721 token via ERC-6551


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

Important that it is assumed the caller of this function is trusted by the Account Group

*Initialize the ERC721AccountRails contract with the initialization data.*


```solidity
function initialize(bytes memory initData) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`initData`|`bytes`|Additional initialization data if required by the contract.|


### receive


```solidity
receive() external payable override(Extensions, IERC6551Account);
```

### supportsInterface

*Declare explicit ERC165 support for ERC1271 interface in addition to existing interfaces*


```solidity
function supportsInterface(bytes4 interfaceId) public view override(AccountRails, ERC6551Account) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interfaceId to check for support|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


### withdrawFromEntryPoint

*Function to withdraw funds using the EntryPoint's `withdrawTo()` function*


```solidity
function withdrawFromEntryPoint(address payable recipient, uint256 amount) public virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address payable`|The address to receive from the EntryPoint balance|
|`amount`|`uint256`|The amount of funds to withdraw from the EntryPoint|


### _checkSenderIsEntryPoint


```solidity
function _checkSenderIsEntryPoint() internal virtual override;
```

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

### _isValidSigner


```solidity
function _isValidSigner(address signer, bytes memory) internal view override returns (bool);
```

### _updateState


```solidity
function _updateState() internal virtual override;
```

### _beforeExecuteCall

*According to ERC6551, functions that modify state must alter the `uint256 state` variable*


```solidity
function _beforeExecuteCall(address to, uint256 value, bytes calldata data)
    internal
    virtual
    override
    returns (address guard, bytes memory checkBeforeData);
```

### owner


```solidity
function owner() public view override returns (address);
```

### _tokenOwner


```solidity
function _tokenOwner(uint256 chainId, address tokenContract, uint256 tokenId) internal view virtual returns (address);
```

### _isAuthorized

*Sensitive account operations restricted to three tiered authorization hierarchy:
TBA owner || TBA permission || AccountGroup admin
This provides owner autonomy, owner-delegated permissions, and multichain AccountGroup management*


```solidity
function _isAuthorized(bytes8 _operation, address _sender) internal view returns (bool);
```

### _isAccountGroupAdmin

*On non-origin chains, `owner()` returns the zero address, so multichain upgrades
are enabled by permitting trusted AccountGroup admins*


```solidity
function _isAccountGroupAdmin(address _sender) internal view returns (bool);
```

### _checkCanUpdateValidators


```solidity
function _checkCanUpdateValidators() internal virtual override;
```

### _checkCanUpdatePermissions


```solidity
function _checkCanUpdatePermissions() internal override;
```

### _checkCanUpdateGuards


```solidity
function _checkCanUpdateGuards() internal override;
```

### _checkCanUpdateInterfaces


```solidity
function _checkCanUpdateInterfaces() internal override;
```

### _checkCanUpdateExtensions

*Changes to extensions restricted to TBA owner or AccountGroupAdmin to prevent mutiny*


```solidity
function _checkCanUpdateExtensions() internal override;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override;
```

