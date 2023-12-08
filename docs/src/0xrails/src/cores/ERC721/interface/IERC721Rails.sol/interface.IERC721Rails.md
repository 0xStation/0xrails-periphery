# IERC721Rails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721/interface/IERC721Rails.sol)

using the consistent Access layer, expose external functions for interacting with core token logic


## Functions
### mintTo

*Function to mint ERC721Rails tokens to a recipient*


```solidity
function mintTo(address recipient, uint256 quantity) external returns (uint256 mintStartTokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address of the recipient to receive the minted tokens.|
|`quantity`|`uint256`|The amount of tokens to mint and transfer to the recipient.|


### burn

*Burn ERC721Rails tokens from the caller.*


```solidity
function burn(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token to burn from the sender's balance.|


### initialize

*Initialize the ERC721Rails contract with the given owner, name, symbol, and initialization data.*


```solidity
function initialize(address owner, string calldata name, string calldata symbol, bytes calldata initData) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The initial owner of the contract.|
|`name`|`string`|The name of the ERC721 token.|
|`symbol`|`string`|The symbol of the ERC721 token.|
|`initData`|`bytes`|Additional initialization data if required by the contract.|


