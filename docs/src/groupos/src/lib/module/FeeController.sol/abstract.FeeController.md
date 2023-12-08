# FeeController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/lib/module/FeeController.sol)

**Inherits:**
Ownable

**Author:**
symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth

The FeeController is intended to be inherited by all purchase modules to abstract all payment logic
and handle fees for every client's desired Membership implementation

*This contract enables payment by handling funds when charging base and variable fees on each Membership's mints*


## State Variables
### feeManager
*Address of the deployed FeeManager contract which stores state for all collections' fee information*

*The FeeManager serves a Singleton role as central fee ledger for modules to read from*


```solidity
address internal feeManager;
```


## Functions
### constructor


```solidity
constructor(address _newOwner, address _feeManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|The initialization of the contract's owner address, managed by Station|
|`_feeManager`|`address`|This chain's address for the FeeManager, Station's central fee management ledger|


### setNewFeeManager

*Function to set a new FeeManager*


```solidity
function setNewFeeManager(address newFeeManager) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newFeeManager`|`address`|The new FeeManager address to write to storage|


### withdrawFees

*Function to withdraw the total balances of accrued base and variable eth fees collected from mints*

*Sends fees to the module's owner address, which is managed by Station Network*

*Access control enforced for tax implications*


```solidity
function withdrawFees(address[] calldata paymentTokens) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`paymentTokens`|`address[]`|The token addresses to call, where address(0) represents network token|


### _collectFeeAndForwardCollectionRevenue

*Function to collect fees for owner and collection in both network token and ERC20s*

*Called only by child contracts inheriting this one*


```solidity
function _collectFeeAndForwardCollectionRevenue(
    address collection,
    address payoutAddress,
    address paymentToken,
    address recipient,
    uint256 quantity,
    uint256 unitPrice
) internal returns (uint256 paidFee);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The token collection to mint from|
|`payoutAddress`|`address`|The address to send payment for the collection|
|`paymentToken`|`address`|The token address being used for payment|
|`recipient`|`address`|The recipient of successfully minted tokens|
|`quantity`|`uint256`|The number of items being minted, used to calculate the total fee payment required|
|`unitPrice`|`uint256`|The price per token to mint|


## Events
### FeePaid

```solidity
event FeePaid(
    address indexed collection,
    address indexed buyer,
    address indexed paymentToken,
    uint256 unitPrice,
    uint256 quantity,
    uint256 totalFee
);
```

### FeeWithdrawn

```solidity
event FeeWithdrawn(address indexed recipient, address indexed token, uint256 amount);
```

### FeeManagerUpdated

```solidity
event FeeManagerUpdated(address indexed oldFeeManager, address indexed newFeeManager);
```

## Errors
### InvalidFee

```solidity
error InvalidFee(uint256 expected, uint256 received);
```

