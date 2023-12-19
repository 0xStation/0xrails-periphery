# IExtensionBeaconFollower
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/extension/examples/beacon/IExtensionBeacon.sol)


## Functions
### removeExtensionBeacon

*Function to remove the extension beacon.*


```solidity
function removeExtensionBeacon() external;
```

### refreshExtensionBeacon

*Function to refresh the extension beacon.*


```solidity
function refreshExtensionBeacon(uint40 lastValidUpdatedAt) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lastValidUpdatedAt`|`uint40`|The uint40 timestamp to be set as valid|


### updateExtensionBeacon

*Function to update the extension beacon.*


```solidity
function updateExtensionBeacon(address implementation, uint40 lastValidUpdatedAt) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|The address to set as new extension beacon|
|`lastValidUpdatedAt`|`uint40`|The uint40 timestamp to be set as valid|


## Events
### ExtensionBeaconUpdated

```solidity
event ExtensionBeaconUpdated(address indexed oldBeacon, address indexed newBeacon, uint40 lastValidUpdatedAt);
```

