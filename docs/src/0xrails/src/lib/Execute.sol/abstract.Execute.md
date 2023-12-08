# Execute
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/Execute.sol)

This abstract contract provides functionality for executing *only* calls to other contracts


## Functions
### executeCall

*Execute a call to another contract with the specified target address, value, and data.*


```solidity
function executeCall(address to, uint256 value, bytes calldata data) public returns (bytes memory executeData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The address of the target contract to call.|
|`value`|`uint256`|The amount of native currency to send with the call.|
|`data`|`bytes`|The call's data.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`executeData`|`bytes`|The return data from the executed call.|


### execute

Temporary backwards compatibility with offchain API


```solidity
function execute(address to, uint256 value, bytes calldata data) public returns (bytes memory executeData);
```

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


### _call


```solidity
function _call(address to, uint256 value, bytes calldata data) internal returns (bytes memory result);
```

### _checkCanExecuteCall

*Internal function to check if the caller has permission to execute calls.*


```solidity
function _checkCanExecuteCall() internal view virtual;
```

### _beforeExecuteCall

*Hook to perform pre-call checks and return guard information.*


```solidity
function _beforeExecuteCall(address to, uint256 value, bytes calldata data)
    internal
    virtual
    returns (address guard, bytes memory checkBeforeData);
```

### _afterExecuteCall

*Hook to perform post-call checks.*


```solidity
function _afterExecuteCall(address guard, bytes memory checkBeforeData, bytes memory executeData) internal virtual;
```

## Events
### Executed

```solidity
event Executed(address indexed executor, address indexed to, uint256 value, bytes data);
```

