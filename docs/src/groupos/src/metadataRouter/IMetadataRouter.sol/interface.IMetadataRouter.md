# IMetadataRouter
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/metadataRouter/IMetadataRouter.sol)


## Functions
### baseURI

If a route-specific URI is not configured for the contract address, the default URI will be used.

*Get the base URI for a specific route and contract address.*


```solidity
function baseURI(string memory route, address contractAddress) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contractAddress`|`address`|The address of the contract for which to request a URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The base URI for the specified route and contract address.|


### defaultURI

*Get the default URI for cases where no specific URI is configured.*


```solidity
function defaultURI() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The default URI.|


### contractURI

*Get the URI for the MetadataRouter contract itself.*


```solidity
function contractURI() external view returns (string memory uri);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The URI for the MetadataRouter contract.|


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


### uriOf

*Get the full URI for a specific route and contract address.*


```solidity
function uriOf(string memory route, address contractAddress) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contractAddress`|`address`|The address of the contract for which to request a URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The full URI for the specified route and contract address.|


### uriOf

*Get the full URI for a specific route and contract address, with additional appended data.*


```solidity
function uriOf(string memory route, address contractAddress, string memory appendData)
    external
    view
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`route`|`string`|The name of the route.|
|`contractAddress`|`address`|The address of the contract for which the URI is requested.|
|`appendData`|`string`|Additional data to append to the URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|'' The full URI with appended data for the specified route and contract address.|


### tokenURI

*Get the token URI for an NFT tokenId within a specific collection.*


```solidity
function tokenURI(address collection, uint256 tokenId) external view returns (string memory);
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


### setDefaultURI

Only the contract owner can set the default URI.

*Set the default URI to be used when no specific URI is configured.*


```solidity
function setDefaultURI(string memory uri) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The new default URI.|


### setRouteURI

Only the contract owner can set route-specific URIs.

*Set the URI for a specific route.*


```solidity
function setRouteURI(string memory uri, string memory route) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The new URI to be configured for the route.|
|`route`|`string`|The name of the route.|


### setContractRouteURI

Only the contract owner can set contract-specific URIs.

*Set the URI for a specific route and contract address.*


```solidity
function setContractRouteURI(string memory uri, string memory route, address contractAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The new URI to be configured for the route and contract address.|
|`route`|`string`|The name of the route.|
|`contractAddress`|`address`|The address of the contract for which the URI is configured.|


## Events
### DefaultURIUpdated

```solidity
event DefaultURIUpdated(string uri);
```

### RouteURIUpdated

```solidity
event RouteURIUpdated(string route, string uri);
```

### ContractRouteURIUpdated

```solidity
event ContractRouteURIUpdated(string route, string uri, address indexed contractAddress);
```

