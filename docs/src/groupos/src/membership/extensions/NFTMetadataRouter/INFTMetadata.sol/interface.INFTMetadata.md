# INFTMetadata
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol)


## Functions
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

