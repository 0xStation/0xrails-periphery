# TimeVersionedBeaconFollower
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/TimeVersionedBeaconFollower.sol)


## Functions
### remove

*Remove the reference to the implementation from the TimeVersionedBeacon.*


```solidity
function remove(TimeVersionedBeacon storage beacon) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`beacon`|`TimeVersionedBeacon`|The TimeVersionedBeacon in storage to remove.|


### refresh

*Refresh the TimeVersionedBeacon with a new timestamp.*


```solidity
function refresh(TimeVersionedBeacon storage beacon, uint40 lastValidUpdatedAt) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`beacon`|`TimeVersionedBeacon`|The TimeVersionedBeacon in storage to refresh.|
|`lastValidUpdatedAt`|`uint40`|The new timestamp of last valid update.|


### update

*Update the TimeVersionedBeacon with a new implementation and timestamp.*


```solidity
function update(TimeVersionedBeacon storage beacon, address implementation, uint40 lastValidUpdatedAt) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`beacon`|`TimeVersionedBeacon`|The TimeVersionedBeacon storage to update.|
|`implementation`|`address`|The new implementation address to set.|
|`lastValidUpdatedAt`|`uint40`|The new timestamp of last valid update.|


### set

*Internal function to set the implementation and lastValidUpdatedAt of a TimeVersionedBeacon.*


```solidity
function set(TimeVersionedBeacon storage beacon, address implementation, uint40 lastValidUpdatedAt) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`beacon`|`TimeVersionedBeacon`|The TimeVersionedBeacon storage to update.|
|`implementation`|`address`|The new implementation address to set.|
|`lastValidUpdatedAt`|`uint40`|The new timestamp of last valid update.|


## Structs
### TimeVersionedBeacon

```solidity
struct TimeVersionedBeacon {
    address implementation;
    uint40 lastValidUpdatedAt;
}
```

