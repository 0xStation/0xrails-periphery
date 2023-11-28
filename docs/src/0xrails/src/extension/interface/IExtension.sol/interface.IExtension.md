# IExtension
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/interface/IExtension.sol)


## Functions
### signatureOf

*Function to get the signature string for a specific function selector.*


```solidity
function signatureOf(bytes4 selector) external pure returns (string memory signature);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`selector`|`bytes4`|The function selector to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`signature`|`string`|The signature string for the given function.|


### getAllSelectors

*Function to get an array of all recognized function selectors.*


```solidity
function getAllSelectors() external pure returns (bytes4[] memory selectors);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`selectors`|`bytes4[]`|An array containing all 4-byte function selectors.|


### getAllSignatures

*Function to get an array of all recognized function signature strings.*


```solidity
function getAllSignatures() external pure returns (string[] memory signatures);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`signatures`|`string[]`|An array containing all function signature strings.|


