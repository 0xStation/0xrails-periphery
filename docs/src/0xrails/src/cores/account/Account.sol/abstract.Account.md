# Account
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/Account.sol)

**Inherits:**
[IAccount](/src/lib/ERC4337/interface/IAccount.sol/interface.IAccount.md), ERC721Holder, ERC1155Holder

*This contract provides the basic logic for implementing the IAccount interface - validateUserOp*


## State Variables
### entryPoint
*This chain's EntryPoint contract address*


```solidity
address public immutable entryPoint;
```


### VALIDATOR_FLAG
To use, prepend signatures with a 32-byte word packed with 8-byte flag and target validator address,
Leaving 4 empty bytes inbetween the packed values.
Ie: `bytes32 validatorData == 0xf88284b100000000 | bytes32(uint256(uint160(address(callPermitValidator))));`

*8-Byte value signaling support for modular validation schema developed by GroupOS*


```solidity
bytes8 public constant VALIDATOR_FLAG = bytes8(bytes4(keccak256("VALIDATORFLAG"))) & 0xFFFFFFFF00000000;
```


## Functions
### constructor


```solidity
constructor(address _entryPointAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_entryPointAddress`|`address`|The contract address for this chain's ERC-4337 EntryPoint contract Official address for the most recent EntryPoint version is `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`|


### getEntryPointBalance

*View function to view the EntryPoint's deposit balance for this Account*


```solidity
function getEntryPointBalance() public view returns (uint256);
```

### preFundEntryPoint

*Function to pre-fund the EntryPoint contract's `depositTo()` function
using payable call context + this contract's native currency balance*


```solidity
function preFundEntryPoint() public payable virtual;
```

### withdrawFromEntryPoint

*Function to withdraw funds using the EntryPoint's `withdrawTo()` function*


```solidity
function withdrawFromEntryPoint(address payable recipient, uint256 amount) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address payable`|The address to receive from the EntryPoint balance|
|`amount`|`uint256`|The amount of funds to withdraw from the EntryPoint|


