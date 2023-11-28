# MintCreateInitializeController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/module/MintCreateInitializeController.sol)

**Inherits:**
[PermitController](/src/lib/module/PermitController.sol/abstract.PermitController.md), [SetupController](/src/lib/module/SetupController.sol/abstract.SetupController.md), [ERC6551AccountController](/src/lib/module/ERC6551AccountController.sol/abstract.ERC6551AccountController.md)


## State Variables
### _disablePermits
*collection => permits disabled, permits are enabled by default*


```solidity
mapping(address => bool) internal _disablePermits;
```


## Functions
### constructor


```solidity
constructor() PermitController;
```

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

### mintAndCreateAccount

*Mint a single ERC721Rails token and create+initialize its tokenbound account*


```solidity
function mintAndCreateAccount(MintParams calldata mintParams)
    external
    usePermits(_encodePermitContext(mintParams.collection))
    returns (address account, uint256 newTokenId);
```

### _encodePermitContext


```solidity
function _encodePermitContext(address collection) internal pure returns (bytes memory context);
```

### _decodePermitContext


```solidity
function _decodePermitContext(bytes memory context) internal pure returns (address collection);
```

### requirePermits


```solidity
function requirePermits(bytes memory context) public view override returns (bool);
```

### signerCanPermit


```solidity
function signerCanPermit(address signer, bytes memory context) public view override returns (bool);
```

## Events
### SetUp
*Events share names but differ in parameters to differentiate them between controllers*


```solidity
event SetUp(address indexed collection, bool indexed enablePermits);
```

## Structs
### MintParams

```solidity
struct MintParams {
    address collection;
    address recipient;
    address registry;
    address accountProxy;
    bytes32 salt;
}
```

