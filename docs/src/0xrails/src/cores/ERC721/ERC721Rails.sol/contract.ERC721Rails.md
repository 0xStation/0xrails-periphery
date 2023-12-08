# ERC721Rails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721/ERC721Rails.sol)

**Inherits:**
[Rails](/src/Rails.sol/abstract.Rails.md), [Ownable](/src/access/ownable/Ownable.sol/abstract.Ownable.md), [Initializable](/src/lib/initializable/Initializable.sol/abstract.Initializable.md), [TokenMetadata](/src/cores/TokenMetadata/TokenMetadata.sol/abstract.TokenMetadata.md), [ERC721](/src/cores/ERC721/ERC721.sol/abstract.ERC721.md), [IERC721Rails](/src/cores/ERC721/interface/IERC721Rails.sol/interface.IERC721Rails.md)

This contract implements the Rails pattern to provide enhanced functionality for ERC721 tokens.

*ERC721A chosen for only practical solution for large token supply allocations*


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

*Initialize the ERC721Rails contract with the given owner, name, symbol, and initialization data.*


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


### _startTokenId

*if called within a constructor, self-delegatecall will not work because this address does not yet have
bytecode implementing the init functions -> revert here with nicer error message*

*Override starting tokenId exposed by ERC721A, which is 0 by default*


```solidity
function _startTokenId() internal pure override returns (uint256);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view override(Rails, ERC721) returns (bool);
```

### name

*Function to return the name of a token implementation*


```solidity
function name() public view override(IERC721, TokenMetadata) returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned ERC721 name string|


### symbol

*Function to return the symbol of a token implementation*


```solidity
function symbol() public view override(IERC721, TokenMetadata) returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned ERC721 symbol string|


### tokenURI

Contracts inheriting ERC721A are required to implement `tokenURI()`

*Function to return the ERC721 tokenURI using extended URI logic
from the `TokenURIExtension` contract*


```solidity
function tokenURI(uint256 tokenId) public view override returns (string memory);
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

*Function to mint ERC721Rails tokens to a recipient*


```solidity
function mintTo(address recipient, uint256 quantity)
    external
    onlyPermission(Operations.MINT)
    returns (uint256 mintStartTokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address of the recipient to receive the minted tokens.|
|`quantity`|`uint256`|The amount of tokens to mint and transfer to the recipient.|


### burn

*Burn ERC721Rails tokens from the caller.*


```solidity
function burn(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token to burn from the sender's balance.|


### _beforeTokenTransfers

*Hook called before token transfers. Calls into the given guard.
Provides one of three token operations and its accompanying data to the guard.*


```solidity
function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity)
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
function _checkCanTransfer(address account, uint256 tokenId) internal virtual override;
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

