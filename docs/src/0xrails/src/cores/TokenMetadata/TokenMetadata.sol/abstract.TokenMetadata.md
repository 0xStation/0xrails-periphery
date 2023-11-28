# TokenMetadata
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/TokenMetadata/TokenMetadata.sol)

**Inherits:**
[ITokenMetadata](/src/cores/TokenMetadata/ITokenMetadata.sol/interface.ITokenMetadata.md)


## Functions
### name

*Function to return the name of a token implementation*


```solidity
function name() public view virtual returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned name string|


### symbol

*Function to return the symbol of a token implementation*


```solidity
function symbol() public view virtual returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned symbol string|


### setName

*Function to set the name for a token implementation*


```solidity
function setName(string calldata name_) external canUpdateTokenMetadata;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|The name string to set|


### setSymbol

*Function to set the symbol for a token implementation*


```solidity
function setSymbol(string calldata symbol_) external canUpdateTokenMetadata;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`symbol_`|`string`|The symbol string to set|


### _setName


```solidity
function _setName(string calldata name_) internal;
```

### _setSymbol


```solidity
function _setSymbol(string calldata symbol_) internal;
```

### canUpdateTokenMetadata


```solidity
modifier canUpdateTokenMetadata();
```

### _checkCanUpdateTokenMetadata

*Function to implement access control restricting setter functions*


```solidity
function _checkCanUpdateTokenMetadata() internal view virtual;
```

