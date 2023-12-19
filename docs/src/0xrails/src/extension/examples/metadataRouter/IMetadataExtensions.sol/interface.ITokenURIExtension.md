# ITokenURIExtension
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/metadataRouter/IMetadataExtensions.sol)


## Functions
### ext_tokenURI

Intended to be invoked in the context of a delegatecall

*Function to extend the `tokenURI()` function*


```solidity
function ext_tokenURI(uint256 tokenId) external view returns (string memory);
```

