# MetadataRouter
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/metadataRouter/MetadataRouter.sol)

**Inherits:**
Initializable, Ownable, UUPSUpgradeable, [IMetadataRouter](/src/metadataRouter/IMetadataRouter.sol/interface.IMetadataRouter.md)

This contract implements a metadata routing mechanism that allows for dynamic configuration
of URIs associated with different routes and contract addresses. It enables fetching metadata
URIs based on routes and contract addresses, providing flexibility for managing metadata for
various contracts and use cases.


## Functions
### constructor


```solidity
constructor() Initializable;
```

### initialize

The contract owner will have exclusive rights to manage metadata routes and URIs.

*Initialize the contract with ownership information.*


```solidity
function initialize(address _owner) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The address of the contract owner.|


### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

### contractURI

*Get the URI for the MetadataRouter contract itself.*


```solidity
function contractURI() external view returns (string memory uri);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The URI for the MetadataRouter contract.|


### baseURI

If a route-specific URI is not configured for the contract address, the default URI will be used.

*Get the base URI for a specific route and contract address.*


```solidity
function baseURI(string memory route, address contractAddress) public view returns (string memory uri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contractAddress`|`address`|The address of the contract for which to request a URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|'' The base URI for the specified route and contract address.|


### defaultURI

*Get the default URI for cases where no specific URI is configured.*


```solidity
function defaultURI() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The default URI.|


### routeURI

*Get the URI configured for a specific route.*


```solidity
function routeURI(string memory route) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|uri The URI configured for the specified route.|


### contractRouteURI

*Get the URI configured for a specific route and contract address.*


```solidity
function contractRouteURI(string memory route, address contractAddress) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contractAddress`|`address`|The address of the contract for which to request a URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The URI configured for the specified route and contract address.|


### _getContractRouteURI


```solidity
function _getContractRouteURI(string memory route, address contractAddress) internal view returns (string memory);
```

### setDefaultURI

Only the contract owner can set the default URI.

*Set the default URI to be used when no specific URI is configured.*


```solidity
function setDefaultURI(string memory uri) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The new default URI.|


### setRouteURI

Only the contract owner can set route-specific URIs.

*Set the URI for a specific route.*


```solidity
function setRouteURI(string memory route, string memory uri) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`uri`|`string`|The new URI to be configured for the route.|


### setContractRouteURI

Only the contract owner can set contract-specific URIs.

*Set the URI for a specific route and contract address.*


```solidity
function setContractRouteURI(string memory route, string memory uri, address contractAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`uri`|`string`|The new URI to be configured for the route and contract address.|
|`contractAddress`|`address`|The address of the contract for which the URI is configured.|


### uriOf

*Get the full URI for a specific route and contract address.*


```solidity
function uriOf(string memory route, address contract_) public view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contract_`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The full URI for the specified route and contract address.|


### uriOf

*Get the full URI for a specific route and contract address.*


```solidity
function uriOf(string memory route, address contract_, string memory appendData) public view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contract_`|`address`||
|`appendData`|`string`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The full URI for the specified route and contract address.|


### tokenURI

*Get the token URI for an NFT tokenId within a specific collection.*


```solidity
function tokenURI(address collection, uint256 tokenId) public view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The address of the NFT collection contract.|
|`tokenId`|`uint256`|The ID of the NFT token within the collection.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The token URI for the specified NFT token.|


