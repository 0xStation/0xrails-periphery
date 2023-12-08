# IStakeManager
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC4337/interface/IStakeManager.sol)

**Author:**
Live ERC-4337 EntryPoint Contract Deployment:
https://etherscan.io/address/0x5ff137d4b0fdcd49dca30c7cf57e578a026d2789#code

*Interface contract taken from the live ERC-4337 EntryPoint,
used to manage deposits and withdrawals for IEntryPoint interface*


## Functions
### getDepositInfo


```solidity
function getDepositInfo(address account) external view returns (DepositInfo memory info);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`info`|`DepositInfo`|- full deposit information of given account|


### balanceOf


```solidity
function balanceOf(address account) external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the deposit (for gas payment) of the account|


### depositTo

add to the deposit of the given account


```solidity
function depositTo(address account) external payable;
```

### addStake

add to the account's stake - amount and delay
any pending unstake is first cancelled.


```solidity
function addStake(uint32 _unstakeDelaySec) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_unstakeDelaySec`|`uint32`|the new lock duration before the deposit can be withdrawn.|


### unlockStake

attempt to unlock the stake.
the value can be withdrawn (using withdrawStake) after the unstake delay.


```solidity
function unlockStake() external;
```

### withdrawStake

withdraw from the (unlocked) stake.
must first call unlockStake and wait for the unstakeDelay to pass


```solidity
function withdrawStake(address payable withdrawAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`withdrawAddress`|`address payable`|the address to send withdrawn value.|


### withdrawTo

withdraw from the deposit.


```solidity
function withdrawTo(address payable withdrawAddress, uint256 withdrawAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`withdrawAddress`|`address payable`|the address to send withdrawn value.|
|`withdrawAmount`|`uint256`|the amount to withdraw.|


## Events
### Deposited

```solidity
event Deposited(address indexed account, uint256 totalDeposit);
```

### Withdrawn

```solidity
event Withdrawn(address indexed account, address withdrawAddress, uint256 amount);
```

### StakeLocked
Emitted when stake or unstake delay are modified


```solidity
event StakeLocked(address indexed account, uint256 totalStaked, uint256 unstakeDelaySec);
```

### StakeUnlocked
Emitted once a stake is scheduled for withdrawal


```solidity
event StakeUnlocked(address indexed account, uint256 withdrawTime);
```

### StakeWithdrawn

```solidity
event StakeWithdrawn(address indexed account, address withdrawAddress, uint256 amount);
```

## Structs
### DepositInfo
*sizes were chosen so that (deposit,staked, stake) fit into one cell (used during handleOps)
and the rest fit into a 2nd cell.
112 bit allows for 10^15 eth
48 bit for full timestamp
32 bit allows 150 years for unstake delay*


```solidity
struct DepositInfo {
    uint112 deposit;
    bool staked;
    uint112 stake;
    uint32 unstakeDelaySec;
    uint48 withdrawTime;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`deposit`|`uint112`|the entity's deposit|
|`staked`|`bool`|true if this entity is staked.|
|`stake`|`uint112`|actual amount of ether staked for this entity.|
|`unstakeDelaySec`|`uint32`|minimum delay to withdraw the stake.|
|`withdrawTime`|`uint48`|- first block timestamp where 'withdrawStake' will be callable, or zero if already locked|

