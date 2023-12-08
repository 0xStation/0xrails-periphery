# FreeMintController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/modules/FreeMintController.sol)

**Inherits:**
[SetupController](/src/lib/module/SetupController.sol/abstract.SetupController.md), [PermitController](/src/lib/module/PermitController.sol/abstract.PermitController.md), [FeeController](/src/lib/module/FeeController.sol/abstract.FeeController.md)

**Author:**
symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth

*Provides a modular contract to handle collections who wish for their membership mints to be
free of charge, save for Station Network's base fee*


## State Variables
### _disablePermits
*collection => permits disabled, permits are enabled by default*


```solidity
mapping(address => bool) internal _disablePermits;
```


## Functions
### constructor


```solidity
constructor(address _newOwner, address _feeManager) PermitController FeeController(_newOwner, _feeManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|The owner of the FeeControllerV2, an address managed by Station Network|
|`_feeManager`|`address`|The FeeManager's address|


### setUp

*Function to set up and configure a new collection*


```solidity
function setUp(address collection, bool enablePermits) public canSetUp(collection);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The new collection to configure|
|`enablePermits`|`bool`|A boolean to represent whether this collection will repeal or support grant functionality|


### setUp

*convenience function for setting up when creating collections, relies on auth done in public setUp*


```solidity
function setUp(bool enablePermits) external;
```

### mint

*Function to mint a single collection token to the caller, ie a user*


```solidity
function mint(address collection) external payable;
```

### mintTo

*Function to mint a single collection token to a specified recipient*


```solidity
function mintTo(address collection, address recipient) external payable;
```

### batchMint

returned tokenId range is inclusive

*Function to mint collection tokens in batches to the caller, ie a user*


```solidity
function batchMint(address collection, uint256 amount) external payable;
```

### batchMintTo

returned tokenId range is inclusive

*Function to mint collection tokens in batches to a specified recipient*


```solidity
function batchMintTo(address collection, address recipient, uint256 amount) external payable;
```

### _batchMint

*Internal function to which all external user + client facing batchMint functions are routed.*


```solidity
function _batchMint(address collection, address recipient, uint256 quantity)
    internal
    usePermits(_encodePermitContext(collection));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The token collection to mint from|
|`recipient`|`address`|The recipient of successfully minted tokens|
|`quantity`|`uint256`|The quantity of tokens to mint|


### _encodePermitContext


```solidity
function _encodePermitContext(address collection) internal pure returns (bytes memory context);
```

### _decodePermitContext


```solidity
function _decodePermitContext(bytes memory context) internal pure returns (address collection);
```

### signerCanPermit


```solidity
function signerCanPermit(address signer, bytes memory context) public view override returns (bool);
```

### requirePermits


```solidity
function requirePermits(bytes memory context) public view override returns (bool);
```

## Events
### SetUp
*Events share names but differ in parameters to differentiate them between controllers*


```solidity
event SetUp(address indexed collection, bool indexed enablePermits);
```

