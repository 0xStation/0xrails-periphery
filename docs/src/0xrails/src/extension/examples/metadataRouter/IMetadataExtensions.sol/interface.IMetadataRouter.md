# IMetadataRouter
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/metadataRouter/IMetadataExtensions.sol)


## Functions
### tokenURI

*Returns the token URI*


```solidity
function tokenURI(address contractAddress, uint256 tokenId) external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The returned tokenURI string|


### contractURI

*Returns the contract URI, a modern standard for NFTs*


```solidity
function contractURI(address contractAddress) external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The returned contractURI string|


