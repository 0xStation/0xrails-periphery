# Operations
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/Operations.sol)


## State Variables
### ADMIN

```solidity
bytes8 constant ADMIN = 0xfd45ddde6135ec42;
```


### MINT

```solidity
bytes8 constant MINT = 0x38381131ea27ecba;
```


### BURN

```solidity
bytes8 constant BURN = 0xf951edb3fd4a16a3;
```


### TRANSFER

```solidity
bytes8 constant TRANSFER = 0x5cc15eb80ba37777;
```


### METADATA

```solidity
bytes8 constant METADATA = 0x0e5de49ee56c0bd3;
```


### PERMISSIONS

```solidity
bytes8 constant PERMISSIONS = 0x96bbcfa480f6f1a8;
```


### GUARDS

```solidity
bytes8 constant GUARDS = 0x53cbed5bdabf52cc;
```


### VALIDATOR

```solidity
bytes8 constant VALIDATOR = 0xa95257aebefccffa;
```


### CALL

```solidity
bytes8 constant CALL = 0x706a455ca44ffc9f;
```


### INTERFACE

```solidity
bytes8 constant INTERFACE = 0x4a9bf2931aa5eae4;
```


### INITIALIZE_ACCOUNT

```solidity
bytes8 constant INITIALIZE_ACCOUNT = 0x18b11501aca1cd5e;
```


### MINT_PERMIT

```solidity
bytes8 constant MINT_PERMIT = 0x0b6c53f325d325d3;
```


### BURN_PERMIT

```solidity
bytes8 constant BURN_PERMIT = 0x6801400fea7cd7c7;
```


### TRANSFER_PERMIT

```solidity
bytes8 constant TRANSFER_PERMIT = 0xa994951607abf93b;
```


### CALL_PERMIT

```solidity
bytes8 constant CALL_PERMIT = 0xc8d1733b0840734c;
```


### INITIALIZE_ACCOUNT_PERMIT

```solidity
bytes8 constant INITIALIZE_ACCOUNT_PERMIT = 0x449384b01ca84f74;
```


## Functions
### nameOperation

*Function to provide the signature string corresponding to an 8-byte operation*


```solidity
function nameOperation(bytes8 operation) public pure returns (string memory name);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operation`|`bytes8`||


