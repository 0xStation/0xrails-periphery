# ITokenFactory
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/factory/ITokenFactory.sol)


## Functions
### initialize

*Initializes the proxy for the factory*


```solidity
function initialize(address owner_, address erc20Impl_, address erc721Impl_, address erc1155Impl_) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner_`|`address`|The owner address to be set for the factory contract|
|`erc20Impl_`|`address`||
|`erc721Impl_`|`address`||
|`erc1155Impl_`|`address`||


### createERC20

*Function to create a new ERC20 token proxy using given data*


```solidity
function createERC20(
    address payable implementation,
    bytes32 inputSalt,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
) external returns (address payable token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address payable`|The logic implementation address to be set for the created proxy|
|`inputSalt`|`bytes32`|A 32-byte salt to enable consistent addresses across chains and prevent collision|
|`owner`|`address`|The owner address to be set for the new token proxy|
|`name`|`string`|The token name string|
|`symbol`|`string`|The token symbol string|
|`initData`|`bytes`|Data to pass to `initialize()` on the created token proxy|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address payable`|The created token proxy address|


### createERC721

*Function to create a new ERC721 token proxy using given data*


```solidity
function createERC721(
    address payable implementation,
    bytes32 inputSalt,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
) external returns (address payable token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address payable`|The logic implementation address to be set for the created proxy|
|`inputSalt`|`bytes32`|A 32-byte salt to enable consistent addresses across chains and prevent collision|
|`owner`|`address`|The owner address to be set for the new token proxy|
|`name`|`string`|The token name string|
|`symbol`|`string`|The token symbol string|
|`initData`|`bytes`|Data to pass to `initialize()` on the created token proxy|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address payable`|The created token proxy address|


### createERC1155

*Function to create a new ERC1155 token proxy using given data*


```solidity
function createERC1155(
    address payable implementation,
    bytes32 inputSalt,
    address owner,
    string memory name,
    string memory symbol,
    bytes calldata initData
) external returns (address payable token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address payable`|The logic implementation address to be set for the created proxy|
|`inputSalt`|`bytes32`|A 32-byte salt to enable consistent addresses across chains and prevent collision|
|`owner`|`address`|The owner address to be set for the new token proxy|
|`name`|`string`|The token name string|
|`symbol`|`string`|The token symbol string|
|`initData`|`bytes`|Data to pass to `initialize()` on the created token proxy|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address payable`|The created token proxy address|


### addImplementation

*Function to add a recognized token implementation (packed with its ERC standard enum)*


```solidity
function addImplementation(TokenFactoryStorage.TokenImpl memory tokenImpl) external;
```

### removeImplementation

*Function to remove a recognized token implementation (packed with its ERC standard enum)*


```solidity
function removeImplementation(TokenFactoryStorage.TokenImpl memory tokenImpl) external;
```

## Events
### ERC20Created

```solidity
event ERC20Created(address indexed token);
```

### ERC721Created

```solidity
event ERC721Created(address indexed token);
```

### ERC1155Created

```solidity
event ERC1155Created(address indexed token);
```

### ImplementationSet

```solidity
event ImplementationSet(address indexed newImplementation, TokenStandard indexed standard);
```

## Errors
### InvalidImplementation

```solidity
error InvalidImplementation();
```

## Enums
### TokenStandard

```solidity
enum TokenStandard {
    ERC20,
    ERC721,
    ERC1155
}
```

