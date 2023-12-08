# MetadataRouterStorage
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/metadataRouter/MetadataRouterStorage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0xfed67aa0cf3b192df78e3e317c2e0f80e47fc77b946bcf059a08f848f9e4f400;
```


## Functions
### layout


```solidity
function layout() internal pure returns (Layout storage l);
```

## Structs
### Layout

```solidity
struct Layout {
    string defaultURI;
    mapping(string => string) routeURI;
    mapping(string => mapping(address => string)) contractRouteURI;
}
```

