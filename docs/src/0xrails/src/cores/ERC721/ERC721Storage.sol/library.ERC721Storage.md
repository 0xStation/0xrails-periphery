# ERC721Storage
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC721/ERC721Storage.sol)


## State Variables
### SLOT

```solidity
bytes32 internal constant SLOT = 0x47128c4db77b17da64f911b687ea48877ae0378dea32ab30dfa81e60251d2a00;
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
    uint256 currentIndex;
    uint256 burnCounter;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
    mapping(uint256 => TokenData) tokens;
    mapping(address => OwnerData) owners;
}
```

### TokenData

```solidity
struct TokenData {
    address owner;
    uint48 ownerUpdatedAt;
    bool burned;
    bool nextInitialized;
}
```

### OwnerData

```solidity
struct OwnerData {
    uint64 balance;
    uint64 numMinted;
    uint64 numBurned;
}
```

