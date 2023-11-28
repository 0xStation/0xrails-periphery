# ERC6551Account
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC6551/ERC6551Account.sol)

**Inherits:**
[IERC6551Account](/src/lib/ERC6551/interface/IERC6551Account.sol/interface.IERC6551Account.md)


## Functions
### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```

### isValidSigner


```solidity
function isValidSigner(address signer, bytes calldata data) external view returns (bytes4 magicValue);
```

### token


```solidity
function token() public view returns (uint256 chainId, address tokenContract, uint256 tokenId);
```

### state


```solidity
function state() public view returns (uint256);
```

### _updateState


```solidity
function _updateState() internal virtual;
```

### _isValidSigner


```solidity
function _isValidSigner(address signer, bytes memory) internal view virtual returns (bool);
```

