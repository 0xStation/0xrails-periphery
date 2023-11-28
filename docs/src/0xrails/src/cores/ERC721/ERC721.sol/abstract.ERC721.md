# ERC721
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721/ERC721.sol)

**Inherits:**
[Initializable](/src/lib/initializable/Initializable.sol/abstract.Initializable.md), [IERC721](/src/cores/ERC721/interface/IERC721.sol/interface.IERC721.md)


## State Variables
### MAX_MINT_BATCH_SIZE
*Large batch mints of ERC721A tokens can result in high gas costs upon first transfer of high tokenIds
To improve UX for token owners unaware of this fact, a mint batch size of 500 is enforced*


```solidity
uint256 public constant MAX_MINT_BATCH_SIZE = 500;
```


## Functions
### totalSupply


```solidity
function totalSupply() public view returns (uint256);
```

### totalMinted


```solidity
function totalMinted() public view returns (uint256);
```

### totalBurned


```solidity
function totalBurned() public view returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address owner) public view returns (uint256);
```

### numberMinted


```solidity
function numberMinted(address owner) public view returns (uint256);
```

### numberBurned


```solidity
function numberBurned(address owner) public view returns (uint256);
```

### ownerOf


```solidity
function ownerOf(uint256 tokenId) public view returns (address);
```

### getApproved


```solidity
function getApproved(uint256 tokenId) public view virtual returns (address);
```

### isApprovedForAll


```solidity
function isApprovedForAll(address owner, address operator) public view virtual returns (bool);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```

### approve


```solidity
function approve(address to, uint256 tokenId) public virtual;
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) public virtual;
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 tokenId) public;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) public;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
```

### _initialize


```solidity
function _initialize() internal onlyInitializing;
```

### _startTokenId


```solidity
function _startTokenId() internal view virtual returns (uint256);
```

### _nextTokenId


```solidity
function _nextTokenId() internal view virtual returns (uint256);
```

### _batchMarkerDataOf

Returns the token data for the token marking this batch mint

*If tokenId was minted in a batch and tokenId is not the first id in the batch,
then the returned data will be for a different tokenId.*


```solidity
function _batchMarkerDataOf(uint256 tokenId) private view returns (ERC721Storage.TokenData memory);
```

### _exists


```solidity
function _exists(uint256 tokenId) internal view virtual returns (bool);
```

### _approve


```solidity
function _approve(address operator, uint256 tokenId) internal;
```

### _setApprovalForAll


```solidity
function _setApprovalForAll(address operator, bool approved) internal;
```

### _mint


```solidity
function _mint(address to, uint256 quantity) internal;
```

### _burn

*is there a clean way to combine these two operations into one write while preserving the nice syntax?*

*approval checks are not made in this internal function, make them when wrapping in a public function*


```solidity
function _burn(uint256 tokenId) internal;
```

### _transfer

*is there a clean way to combine these two operations into one write while preserving the nice syntax?
next token is uninitialized so set:
- owner = batch marker owner
- ownerUpdatedAt = batch marker ownerUpdatedAt
- burned = false
- nextInitialized = false*

*approval checks are not made in this internal function, make them when wrapping in a public function*


```solidity
function _transfer(address from, address to, uint256 tokenId) internal;
```

### _safeMint

next token is uninitialized so set:
- owner = batch marker owner
- ownerUpdatedAt = batch marker ownerUpdatedAt
- burned = false
- nextInitialized = false


```solidity
function _safeMint(address to, uint256 quantity) internal virtual;
```

### _safeTransfer

*why does this need to be checked in a loop versus once?*


```solidity
function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual;
```

### _checkCanTransfer


```solidity
function _checkCanTransfer(address account, uint256 tokenId) internal virtual;
```

### _checkOnERC721Received


```solidity
function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) internal;
```

### _beforeTokenTransfers


```solidity
function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity)
    internal
    virtual
    returns (address guard, bytes memory beforeCheckData);
```

### _afterTokenTransfers


```solidity
function _afterTokenTransfers(address guard, bytes memory beforeCheckData) internal virtual;
```

