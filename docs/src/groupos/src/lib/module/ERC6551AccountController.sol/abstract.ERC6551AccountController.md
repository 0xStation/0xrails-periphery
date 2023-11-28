# ERC6551AccountController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/lib/module/ERC6551AccountController.sol)


## Functions
### _createAccount


```solidity
function _createAccount(
    address registry,
    address accountProxy,
    bytes32 salt,
    uint256 chainId,
    address collection,
    uint256 tokenId
) internal returns (address account);
```

### _initializeAccount


```solidity
function _initializeAccount(address account, address accountImpl, bytes memory initData) internal;
```

