# MetadataRouterExtension
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/metadataRouter/MetadataRouterExtension.sol)

**Inherits:**
[Extension](/src/extension/Extension.sol/abstract.Extension.md), [MetadataRouterExtensionData](/src/extension/examples/metadataRouter/MetadataRouterExtensionData.sol/abstract.MetadataRouterExtensionData.md), [ITokenURIExtension](/src/extension/examples/metadataRouter/IMetadataExtensions.sol/interface.ITokenURIExtension.md), [IContractURIExtension](/src/extension/examples/metadataRouter/IMetadataExtensions.sol/interface.IContractURIExtension.md)


## Functions
### getAllSelectors


```solidity
function getAllSelectors() public pure override returns (bytes4[] memory selectors);
```

### signatureOf


```solidity
function signatureOf(bytes4 selector) public pure override returns (string memory);
```

### contractURI

The returned contractURI string is empty in this case.

*Returns the contract URI for this contract, a modern standard for NFTs*


```solidity
function contractURI() external pure returns (string memory uri);
```

### ext_tokenURI

Intended to be invoked in the context of a delegatecall

*Function to extend the `tokenURI()` function*


```solidity
function ext_tokenURI(uint256 tokenId) external view returns (string memory);
```

### ext_contractURI

Intended to be invoked in the context of a delegatecall

*Function to extend the `contractURI()` function*


```solidity
function ext_contractURI() external view returns (string memory);
```

