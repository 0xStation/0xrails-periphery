# TimeRangeGuard
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/guard/examples/TimeRangeGuard.sol)

**Inherits:**
[IGuard](/src/guard/interface/IGuard.sol/interface.IGuard.md)

Example Guard for setting valid time ranges for given operations


## State Variables
### _validTimeRange

```solidity
mapping(address => TimeRange) internal _validTimeRange;
```


## Functions
### contractURI


```solidity
function contractURI() external pure returns (string memory);
```

### setUp


```solidity
function setUp(uint40 start, uint40 end) external;
```

### getValidTimeRange


```solidity
function getValidTimeRange(address primitive) public view returns (uint40 start, uint40 end);
```

### checkBefore


```solidity
function checkBefore(address, bytes calldata) external view returns (bytes memory);
```

### checkAfter


```solidity
function checkAfter(bytes calldata, bytes calldata) external view;
```

### _checkTimeRange


```solidity
function _checkTimeRange() internal view;
```

## Events
### SetUp

```solidity
event SetUp(address indexed primitive, uint40 indexed start, uint40 indexed end);
```

## Structs
### TimeRange

```solidity
struct TimeRange {
    uint40 start;
    uint40 end;
}
```

