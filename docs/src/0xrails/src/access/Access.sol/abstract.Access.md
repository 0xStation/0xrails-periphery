# Access
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/access/Access.sol)

**Inherits:**
[Permissions](/src/access/permissions/Permissions.sol/abstract.Permissions.md)


## Functions
### owner

*Supports multiple owner implementations, e.g. explicit storage vs NFT-owner (ERC-6551)*


```solidity
function owner() public view virtual returns (address);
```

### hasPermission

*Function to check one of 3 permissions criterion is true: owner, admin, or explicit permission*


```solidity
function hasPermission(bytes8 operation, address account) public view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`|The explicit permission to check permission for|
|`account`|`address`|The account address whose permission will be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean value declaring whether or not the address possesses permission for the operation|


### supportsInterface

*Function to implement ERC-165 compliance*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the contract supports the specified interface.|


