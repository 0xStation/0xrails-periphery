# IERC1155Rails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC1155/interface/IERC1155Rails.sol)

using the consistent Access layer, expose external functions for interacting with core token logic


## Functions
### mintTo

*Function to mint ERC1155Rails tokens to a recipient*


```solidity
function mintTo(address recipient, uint256 tokenId, uint256 value) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address of the recipient to receive the minted tokens.|
|`tokenId`|`uint256`|The ID of the token to mint and transfer to the recipient.|
|`value`|`uint256`|The value of the given tokenId to mint and transfer to the recipient.|


### burnFrom

*Function to burn ERC1155Rails tokens from an address.*


```solidity
function burnFrom(address from, uint256 tokenId, uint256 value) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address from which to burn tokens.|
|`tokenId`|`uint256`|The ID of the token to burn from the sender's balance.|
|`value`|`uint256`|The value of the given tokenId to burn from the given address.|


### initialize

*Initialize the ERC1155Rails contract with the given owner, name, symbol, and initialization data.*


```solidity
function initialize(address owner, string calldata name, string calldata symbol, bytes calldata initData) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The initial owner of the contract.|
|`name`|`string`|The name of the ERC1155 token.|
|`symbol`|`string`|The symbol of the ERC1155 token.|
|`initData`|`bytes`|Additional initialization data if required by the contract.|


