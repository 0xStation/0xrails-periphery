# MetadataRouterStorage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/metadataRouter/MetadataRouterExtensionData.sol)


## State Variables
### STORAGE_POSITION

```solidity
bytes32 public constant STORAGE_POSITION =
    keccak256(abi.encode(uint256(keccak256("0xrails.Extensions.MetadataRouterData")) - 1));
```


## Functions
### read


```solidity
function read() internal pure returns (Data storage data);
```

## Structs
### Data

```solidity
struct Data {
    address metadataRouter;
}
```

