# NFTMetadataRouter
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/NFTMetadataRouter/NFTMetadataRouter.sol)

**Inherits:**
[INFTMetadata](/src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol/interface.INFTMetadata.md)


## State Variables
### metadataRouter

```solidity
address public immutable metadataRouter;
```


## Functions
### constructor


```solidity
constructor(address _metadataRouter);
```

### contractURI

Intended to be invoked in the context of a delegatecall

*Returns the contract URI for this contract, a modern standard for NFTs*


```solidity
function contractURI() public view virtual returns (string memory uri);
```

### _contractRoute


```solidity
function _contractRoute() internal pure virtual returns (string memory route);
```

### ext_contractURI

Intended to be invoked in the context of a delegatecall

*Function to extend the `contractURI()` function*


```solidity
function ext_contractURI() external view returns (string memory uri);
```

### ext_tokenURI

Intended to be invoked in the context of a delegatecall

*Function to extend the `tokenURI()` function*


```solidity
function ext_tokenURI(uint256 tokenId) external view returns (string memory uri);
```

