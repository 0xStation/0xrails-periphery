# IERC20Rails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC20/interface/IERC20Rails.sol)

using the consistent Access layer, expose external functions for interacting with core token logic


## Functions
### mintTo

*Function to mint ERC20Rails tokens to a recipient*


```solidity
function mintTo(address recipient, uint256 amount) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address of the recipient to receive the minted tokens.|
|`amount`|`uint256`|The amount of tokens to mint and transfer to the recipient.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the minting and transfer were successful.|


### burnFrom

*Burn ERC20Rails tokens from an address.*


```solidity
function burnFrom(address from, uint256 amount) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address from which the tokens will be burned.|
|`amount`|`uint256`|The amount of tokens to burn from the sender's balance.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the burning was successful.|


### transferFrom

*Transfer ERC20Rails tokens from one address to another.*


```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address from which the tokens will be sent.|
|`to`|`address`|The addres to which the tokens will be delivered.|
|`value`|`uint256`|The amount of tokens to transfer.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_ Boolean indicating whether the transfer was successful.|


### initialize

*Initialize the ERC20Rails contract with the given owner, name, symbol, and initialization data.*


```solidity
function initialize(address owner, string calldata name, string calldata symbol, bytes calldata initData) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The initial owner of the contract.|
|`name`|`string`|The name of the ERC20 token.|
|`symbol`|`string`|The symbol of the ERC20 token.|
|`initData`|`bytes`|Additional initialization data if required by the contract.|


