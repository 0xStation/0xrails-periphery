# Guards
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/guard/Guards.sol)

**Inherits:**
[GuardsInternal](/src/guard/GuardsInternal.sol/abstract.GuardsInternal.md)


## Functions
### supportsInterface

*Function to implement ERC-165 compliance*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


### setGuard

Due to EXTCODESIZE check within `_requireContract()`, this function will revert if called
during the constructor of the contract at `implementation`. Deploy `implementation` contract first.

*Function to set a guard contract for a given operation.*


```solidity
function setGuard(bytes8 operation, address implementation) public virtual canUpdateGuards;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation for which to add a guard contract.|
|`implementation`|`address`|The guard contract address containing code to hook before and after operations|


### removeGuard

*Function to remove a guard for a given operation.*


```solidity
function removeGuard(bytes8 operation) public virtual canUpdateGuards;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The operation for which to remove its guard contract.|


### canUpdateGuards


```solidity
modifier canUpdateGuards();
```

### _checkCanUpdateGuards

Should revert upon failure.

*Function to check if caller possesses sufficient permission to set Guards*


```solidity
function _checkCanUpdateGuards() internal virtual;
```

