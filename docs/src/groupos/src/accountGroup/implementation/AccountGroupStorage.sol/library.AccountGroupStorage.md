# AccountGroupStorage
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/implementation/AccountGroupStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x39147b94183d90fe4f0d54eaae4f5ad1ed9977a9eea5a3e80ef285bd9a9b9300;
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Structs
### Layout
ERC6551 accounts may only upgrade to an account approved by the account group


```solidity
struct Layout {
    address defaultInitializer;
    mapping(uint64 => address) initializerOf;
    address defaultAccountImplementation;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`defaultInitializer`|`address`|The default initialize controller used to configure ERC6551 accounts on deployment|
|`initializerOf`|`mapping(uint64 => address)`|Mapping to override the default initialize controller for a subgroupId|
|`defaultAccountImplementation`|`address`||

