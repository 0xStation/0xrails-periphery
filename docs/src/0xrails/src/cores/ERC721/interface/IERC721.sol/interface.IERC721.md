# IERC721
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721/interface/IERC721.sol)


## Functions
### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint256);
```

### ownerOf


```solidity
function ownerOf(uint256 tokenId) external view returns (address);
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external;
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 tokenId) external;
```

### approve


```solidity
function approve(address to, uint256 tokenId) external;
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) external;
```

### getApproved


```solidity
function getApproved(uint256 tokenId) external view returns (address operator);
```

### isApprovedForAll


```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool);
```

### name


```solidity
function name() external view returns (string memory);
```

### symbol


```solidity
function symbol() external view returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 tokenId) external view returns (string memory);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### totalMinted


```solidity
function totalMinted() external view returns (uint256);
```

### totalBurned


```solidity
function totalBurned() external view returns (uint256);
```

### numberMinted


```solidity
function numberMinted(address tokenOwner) external view returns (uint256);
```

### numberBurned


```solidity
function numberBurned(address tokenOwner) external view returns (uint256);
```

## Events
### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
```

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
```

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
```

## Errors
### ApprovalCallerNotOwnerNorApproved

```solidity
error ApprovalCallerNotOwnerNorApproved();
```

### ApprovalQueryForNonexistentToken

```solidity
error ApprovalQueryForNonexistentToken();
```

### ApprovalInvalidOperator

```solidity
error ApprovalInvalidOperator();
```

### BalanceQueryForZeroAddress

```solidity
error BalanceQueryForZeroAddress();
```

### MintToZeroAddress

```solidity
error MintToZeroAddress();
```

### MintZeroQuantity

```solidity
error MintZeroQuantity();
```

### OwnerQueryForNonexistentToken

```solidity
error OwnerQueryForNonexistentToken();
```

### TransferCallerNotOwnerNorApproved

```solidity
error TransferCallerNotOwnerNorApproved();
```

### TransferFromIncorrectOwner

```solidity
error TransferFromIncorrectOwner();
```

### TransferToNonERC721ReceiverImplementer

```solidity
error TransferToNonERC721ReceiverImplementer();
```

### TransferToZeroAddress

```solidity
error TransferToZeroAddress();
```

### URIQueryForNonexistentToken

```solidity
error URIQueryForNonexistentToken();
```

### MintERC2309QuantityExceedsLimit

```solidity
error MintERC2309QuantityExceedsLimit();
```

### OwnershipNotInitializedForExtraData

```solidity
error OwnershipNotInitializedForExtraData();
```

### ExceedsMaxMintBatchSize

```solidity
error ExceedsMaxMintBatchSize(uint256 quantity);
```

