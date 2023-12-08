# ERC1155
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC1155/ERC1155.sol)

**Inherits:**
[IERC1155](/src/cores/ERC1155/interface/IERC1155.sol/interface.IERC1155.md)


## Functions
### name

*require override*


```solidity
function name() public view virtual returns (string memory);
```

### symbol

*require override*


```solidity
function symbol() public view virtual returns (string memory);
```

### uri

*require override*


```solidity
function uri(uint256 tokenId) public view virtual returns (string memory);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```

### balanceOf


```solidity
function balanceOf(address account, uint256 id) public view virtual returns (uint256);
```

### balanceOfBatch


```solidity
function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
    public
    view
    virtual
    returns (uint256[] memory);
```

### isApprovedForAll


```solidity
function isApprovedForAll(address account, address operator) public view virtual returns (bool);
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) public virtual;
```

### safeTransferFrom


```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public virtual;
```

### safeBatchTransferFrom


```solidity
function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) public virtual;
```

### _setApprovalForAll


```solidity
function _setApprovalForAll(address owner, address operator, bool approved) internal virtual;
```

### _safeTransferFrom


```solidity
function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal;
```

### _safeBatchTransferFrom


```solidity
function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) internal;
```

### _mint


```solidity
function _mint(address to, uint256 id, uint256 value, bytes memory data) internal;
```

### _mintBatch


```solidity
function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal;
```

### _burn


```solidity
function _burn(address from, uint256 id, uint256 value) internal;
```

### _burnBatch


```solidity
function _burnBatch(address from, uint256[] memory ids, uint256[] memory values) internal;
```

### _updateWithAcceptanceCheck


```solidity
function _updateWithAcceptanceCheck(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) internal virtual;
```

### _update

*overriden from OZ by adding totalSupply math*


```solidity
function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual;
```

### _asSingletonArrays


```solidity
function _asSingletonArrays(uint256 element1, uint256 element2)
    private
    pure
    returns (uint256[] memory array1, uint256[] memory array2);
```

### _checkCanTransfer


```solidity
function _checkCanTransfer(address from) internal virtual;
```

### _doSafeTransferAcceptanceCheck


```solidity
function _doSafeTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes memory data
) private;
```

### _doSafeBatchTransferAcceptanceCheck


```solidity
function _doSafeBatchTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) private;
```

### _beforeTokenTransfers


```solidity
function _beforeTokenTransfers(address from, address to, uint256[] memory ids, uint256[] memory values)
    internal
    virtual
    returns (address guard, bytes memory beforeCheckData);
```

### _afterTokenTransfers


```solidity
function _afterTokenTransfers(address guard, bytes memory checkBeforeData) internal virtual;
```

