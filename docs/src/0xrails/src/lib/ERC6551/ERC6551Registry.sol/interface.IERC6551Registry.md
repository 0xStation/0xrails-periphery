# IERC6551Registry
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC6551/ERC6551Registry.sol)


## Functions
### createAccount

*Creates a token bound account for a non-fungible token
If account has already been created, returns the account address without calling create2
If initData is not empty and account has not yet been created, calls account with
provided initData after creation
Emits ERC6551AccountCreated event*


```solidity
function createAccount(address implementation, bytes32 salt, uint256 chainId, address tokenContract, uint256 tokenId)
    external
    returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the address of the account|


### account

*Returns the computed token bound account address for a non-fungible token*


```solidity
function account(address implementation, bytes32 salt, uint256 chainId, address tokenContract, uint256 tokenId)
    external
    view
    returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The computed address of the token bound account|


## Events
### ERC6551AccountCreated
*The registry MUST emit the ERC6551AccountCreated event upon successful account creation*


```solidity
event ERC6551AccountCreated(
    address account,
    address indexed implementation,
    bytes32 salt,
    uint256 chainId,
    address indexed tokenContract,
    uint256 indexed tokenId
);
```

## Errors
### AccountCreationFailed
*The registry MUST revert with AccountCreationFailed error if the create2 operation fails*


```solidity
error AccountCreationFailed();
```

