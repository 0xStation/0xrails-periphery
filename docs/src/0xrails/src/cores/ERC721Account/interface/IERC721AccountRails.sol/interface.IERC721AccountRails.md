# IERC721AccountRails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721Account/interface/IERC721AccountRails.sol)

using the consistent Access layer, expose external functions for interacting with core logic


## Functions
### initialize

*Initialize the ERC721AccountRails contract with the initialization data.*


```solidity
function initialize(bytes calldata initData) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`initData`|`bytes`|Additional initialization data if required by the contract.|


## Errors
### ImplementationNotApproved

```solidity
error ImplementationNotApproved(address implementation);
```

