# ERC6551BytecodeLib
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC6551/ERC6551Registry.sol)


## Functions
### getCreationCode

*Returns the creation code of the token bound account for a non-fungible token*


```solidity
function getCreationCode(
    address implementation_,
    bytes32 salt_,
    uint256 chainId_,
    address tokenContract_,
    uint256 tokenId_
) internal pure returns (bytes memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|the creation code of the token bound account|


