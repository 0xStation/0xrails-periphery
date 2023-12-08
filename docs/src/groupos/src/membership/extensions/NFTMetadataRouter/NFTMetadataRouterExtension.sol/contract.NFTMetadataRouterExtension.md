# NFTMetadataRouterExtension
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/NFTMetadataRouter/NFTMetadataRouterExtension.sol)

**Inherits:**
[NFTMetadataRouter](/src/membership/extensions/NFTMetadataRouter/NFTMetadataRouter.sol/contract.NFTMetadataRouter.md), Extension


## Functions
### constructor


```solidity
constructor(address router) Extension NFTMetadataRouter(router);
```

### _contractRoute


```solidity
function _contractRoute() internal pure override returns (string memory route);
```

### getAllSelectors


```solidity
function getAllSelectors() public pure override returns (bytes4[] memory selectors);
```

### signatureOf


```solidity
function signatureOf(bytes4 selector) public pure override returns (string memory);
```

