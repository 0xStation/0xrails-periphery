# NonceBitMap
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/lib/NonceBitMap.sol)

**Author:**
symmetry (@symmtry69)

Utility for making address-keyed nonce bitmaps for parallelized signature replay protection


## State Variables
### _usedNonces

```solidity
mapping(address => mapping(uint256 => uint256)) internal _usedNonces;
```


## Functions
### isNonceUsed

*Check if a nonce has been used for a specific account.*


```solidity
function isNonceUsed(address account, uint256 nonce) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address for which to check nonce usage.|
|`nonce`|`uint256`|The nonce to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|'' Whether the nonce has been used or not.|


### _useNonce

*Mark a `nonce` as used for a specific `account`, preventing potential replay attacks.*


```solidity
function _useNonce(address account, uint256 nonce) internal;
```

### _split

*Split a nonce into `wordId`, `word`, and `mask` for efficient storage and verification.*


```solidity
function _split(address account, uint256 nonce) private view returns (uint256 wordId, uint256 word, uint256 mask);
```

## Events
### NonceUsed

```solidity
event NonceUsed(address indexed account, uint256 indexed nonce);
```

## Errors
### NonceAlreadyUsed

```solidity
error NonceAlreadyUsed(address account, uint256 nonce);
```

