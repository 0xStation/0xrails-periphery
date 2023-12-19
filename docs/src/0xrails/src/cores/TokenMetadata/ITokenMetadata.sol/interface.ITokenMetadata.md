# ITokenMetadata
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/TokenMetadata/ITokenMetadata.sol)


## Functions
### name

*Function to return the name of a token implementation*


```solidity
function name() external view returns (string calldata);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned name string|


### symbol

*Function to return the symbol of a token implementation*


```solidity
function symbol() external view returns (string calldata);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_ The returned symbol string|


### setName

*Function to set the name for a token implementation*


```solidity
function setName(string calldata name) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The name string to set|


### setSymbol

*Function to set the symbol for a token implementation*


```solidity
function setSymbol(string calldata symbol) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`symbol`|`string`|The symbol string to set|


## Events
### NameUpdated

```solidity
event NameUpdated(string name);
```

### SymbolUpdated

```solidity
event SymbolUpdated(string symbol);
```

