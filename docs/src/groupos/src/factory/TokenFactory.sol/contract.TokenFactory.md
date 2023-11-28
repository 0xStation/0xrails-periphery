# TokenFactory
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/factory/TokenFactory.sol)

**Inherits:**
Initializable, Ownable, UUPSUpgradeable, [ITokenFactory](/src/factory/ITokenFactory.sol/interface.ITokenFactory.md)


## Functions
### constructor


```solidity
constructor() Initializable;
```

### initialize

*Initializes the proxy for the factory*


```solidity
function initialize(address owner_, address erc20Impl_, address erc721Impl_, address erc1155Impl_)
    external
    initializer;
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
) public returns (address payable token);
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
) public returns (address payable token);
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
) public returns (address payable token);
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


### getApprovedImplementations


```solidity
function getApprovedImplementations() public view returns (TokenFactoryStorage.TokenImpl[] memory allImpls);
```

### getApprovedImplementations


```solidity
function getApprovedImplementations(TokenFactoryStorage.TokenStandard standard)
    public
    view
    returns (TokenFactoryStorage.TokenImpl[] memory);
```

### addImplementation

*Function to add a recognized token implementation (packed with its ERC standard enum)*


```solidity
function addImplementation(TokenFactoryStorage.TokenImpl memory tokenImpl) public onlyOwner;
```

### removeImplementation

*Function to remove a recognized token implementation (packed with its ERC standard enum)*


```solidity
function removeImplementation(TokenFactoryStorage.TokenImpl memory tokenImpl) public onlyOwner;
```

### _checkIsApprovedImplementation


```solidity
function _checkIsApprovedImplementation(address _implementation, TokenFactoryStorage.TokenStandard _standard)
    internal;
```

### _addImplementation


```solidity
function _addImplementation(TokenFactoryStorage.TokenImpl memory _tokenImpl) internal;
```

### _removeImplementation


```solidity
function _removeImplementation(TokenFactoryStorage.TokenImpl memory _tokenImpl) internal;
```

### _authorizeUpgrade


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

