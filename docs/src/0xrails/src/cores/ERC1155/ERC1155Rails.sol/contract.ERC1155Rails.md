# ERC1155Rails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC1155/ERC1155Rails.sol)

**Inherits:**
[Rails](/src/Rails.sol/abstract.Rails.md), [Ownable](/src/access/ownable/Ownable.sol/abstract.Ownable.md), [Initializable](/src/lib/initializable/Initializable.sol/abstract.Initializable.md), [TokenMetadata](/src/cores/TokenMetadata/TokenMetadata.sol/abstract.TokenMetadata.md), [ERC1155](/src/cores/ERC1155/ERC1155.sol/abstract.ERC1155.md), [IERC1155Rails](/src/cores/ERC1155/interface/IERC1155Rails.sol/interface.IERC1155Rails.md)

This contract implements the Rails pattern to provide enhanced functionality for ERC1155 tokens.


## Functions
### constructor

Declaring this contract `Initializable()` invokes `_disableInitializers()`,
in order to preemptively mitigate proxy privilege escalation attack vectors


```solidity
constructor() Initializable;
```

### owner

*Owner address is implemented using the `Ownable` contract's function*


```solidity
function owner() public view override(Access, Ownable) returns (address);
```

### initialize

Cannot call initialize within a proxy constructor, only post-deployment in a factory

*Initialize the ERC1155Rails contract with the given owner, name, symbol, and initialization data.*


```solidity
function initialize(address owner_, string calldata name_, string calldata symbol_, bytes calldata initData)
    external
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner_`|`address`||
|`name_`|`string`||
|`symbol_`|`string`||
|`initData`|`bytes`|Additional initialization data if required by the contract.|


### name

*if called within a constructor, self-delegatecall will not work because this address does not yet have
bytecode implementing the init functions -> revert here with nicer error message*

*Function to return the name of a token implementation*


```solidity
function name() public view override(ERC1155, TokenMetadata) returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned ERC1155 name string|


### symbol

*Function to return the symbol of a token implementation*


```solidity
function symbol() public view override(ERC1155, TokenMetadata) returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned ERC1155 symbol string|


### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view override(Rails, ERC1155) returns (bool);
```

### uri

Contracts inheriting ERC1155 are required to implement `uri()`

*Function to return the ERC1155 uri using extended tokenURI logic
from the `TokenURIExtension` contract*


```solidity
function uri(uint256 tokenId) public view override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The token ID for which to query a URI|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned tokenURI string|


### contractURI

Uses extended contract URI logic from the `ContractURIExtension` contract

*Returns the contract URI for this ERC20 token, a modern standard for NFTs*


```solidity
function contractURI() public view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned contractURI string|


### mintTo

*Function to mint ERC1155Rails tokens to a recipient*


```solidity
function mintTo(address recipient, uint256 tokenId, uint256 value) external onlyPermission(Operations.MINT);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address of the recipient to receive the minted tokens.|
|`tokenId`|`uint256`|The ID of the token to mint and transfer to the recipient.|
|`value`|`uint256`|The value of the given tokenId to mint and transfer to the recipient.|


### burnFrom

*Function to burn ERC1155Rails tokens from an address.*


```solidity
function burnFrom(address from, uint256 tokenId, uint256 value) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address from which to burn tokens.|
|`tokenId`|`uint256`|The ID of the token to burn from the sender's balance.|
|`value`|`uint256`|The value of the given tokenId to burn from the given address.|


### _beforeTokenTransfers

*Hook called before token transfers. Calls into the given guard.
Provides one of three token operations and its accompanying data to the guard.*


```solidity
function _beforeTokenTransfers(address from, address to, uint256[] memory ids, uint256[] memory values)
    internal
    view
    override
    returns (address guard, bytes memory beforeCheckData);
```

### _afterTokenTransfers

*Hook called after token transfers. Calls into the given guard.*


```solidity
function _afterTokenTransfers(address guard, bytes memory checkBeforeData) internal view override;
```

### _checkCanTransfer

*Check for `Operations.TRANSFER` permission before ownership and approval*


```solidity
function _checkCanTransfer(address from) internal virtual override;
```

### _checkCanUpdatePermissions

*Restrict Permissions write access to the `Operations.PERMISSIONS` permission*


```solidity
function _checkCanUpdatePermissions() internal view override;
```

### _checkCanUpdateGuards

*Restrict Guards write access to the `Operations.GUARDS` permission*


```solidity
function _checkCanUpdateGuards() internal view override;
```

### _checkCanExecuteCall

*Restrict calls via Execute to the `Operations.EXECUTE` permission*


```solidity
function _checkCanExecuteCall() internal view override;
```

### _checkCanUpdateInterfaces

*Restrict ERC-165 write access to the `Operations.INTERFACE` permission*


```solidity
function _checkCanUpdateInterfaces() internal view override;
```

### _checkCanUpdateTokenMetadata

*Restrict TokenMetadata write access to the `Operations.METADATA` permission*


```solidity
function _checkCanUpdateTokenMetadata() internal view override;
```

### _checkCanUpdateExtensions

*Only the `owner` possesses Extensions write access*


```solidity
function _checkCanUpdateExtensions() internal view override;
```

### _authorizeUpgrade

*Only the `owner` possesses UUPS upgrade rights*


```solidity
function _authorizeUpgrade(address) internal view override;
```

