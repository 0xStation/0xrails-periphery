# IERC1155
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC1155/interface/IERC1155.sol)


## Functions
### uri


```solidity
function uri(uint256 id) external view returns (string memory);
```

### balanceOf


```solidity
function balanceOf(address account, uint256 id) external view returns (uint256);
```

### balanceOfBatch


```solidity
function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
```

### isApprovedForAll


```solidity
function isApprovedForAll(address account, address operator) external view returns (bool);
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) external;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
```

### safeBatchTransferFrom


```solidity
function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
) external;
```

## Events
### TransferSingle

```solidity
event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
```

### TransferBatch

```solidity
event TransferBatch(
    address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
);
```

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed account, address indexed operator, bool approved);
```

### URI

```solidity
event URI(string value, uint256 indexed id);
```

## Errors
### ERC1155InsufficientBalance

```solidity
error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
```

### ERC1155InvalidSender

```solidity
error ERC1155InvalidSender(address sender);
```

### ERC1155InvalidReceiver

```solidity
error ERC1155InvalidReceiver(address receiver);
```

### ERC1155MissingApprovalForAll

```solidity
error ERC1155MissingApprovalForAll(address operator, address owner);
```

### ERC1155InvalidApprover

```solidity
error ERC1155InvalidApprover(address approver);
```

### ERC1155InvalidOperator

```solidity
error ERC1155InvalidOperator(address operator);
```

### ERC1155InvalidArrayLength

```solidity
error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
```

