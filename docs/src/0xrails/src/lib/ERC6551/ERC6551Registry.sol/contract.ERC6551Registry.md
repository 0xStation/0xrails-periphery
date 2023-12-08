# ERC6551Registry
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC6551/ERC6551Registry.sol)

**Inherits:**
[IERC6551Registry](/src/lib/ERC6551/ERC6551Registry.sol/interface.IERC6551Registry.md)


## Functions
### createAccount

*{See IERC6551Registry-createAccount}*


```solidity
function createAccount(address implementation, bytes32 salt, uint256 chainId, address tokenContract, uint256 tokenId)
    external
    returns (address);
```

### account

*{See IERC6551Registry-account}*


```solidity
function account(address implementation, bytes32 salt, uint256 chainId, address tokenContract, uint256 tokenId)
    external
    view
    returns (address);
```

