# FeeManager
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/lib/module/FeeManager.sol)

**Inherits:**
Ownable

**Author:**
👦🏻👦🏻.eth

*This contract stores state for all fees set on both default and per-collection basis
Handles fee calculations when called by modules inquiring about the total fees involved in a mint, including ERC20 support*


## State Variables
### bpsDenominator
*Denominator used to calculate variable fee on a BPS basis*

*Not actually kept in storage as it is marked `constant`, saving gas by putting its value in contract bytecode instead*


```solidity
uint256 private constant bpsDenominator = 10_000;
```


### defaultFees
*Baseline fee struct that serves as a stand in for all token addresses that have been registered
in a stablecoin purchase module but not had their default fees set*


```solidity
Fees internal defaultFees;
```


### tokenFees
*Mapping that stores default fees associated with a given token address*


```solidity
mapping(address => Fees) internal tokenFees;
```


### collectionFees
*Mapping that stores override fees associated with specific collections, i.e. for discounts*


```solidity
mapping(address => mapping(address => Fees)) internal collectionFees;
```


## Functions
### constructor

Constructor will be deprecated in favor of an initialize() UUPS proxy call once logic is finalized & approved


```solidity
constructor(
    address _newOwner,
    uint120 _defaultBaseFee,
    uint120 _defaultVariableFee,
    uint120 _networkTokenBaseFee,
    uint120 _networkTokenVariableFee
);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|The initialization of the contract's owner address, managed by Station|
|`_defaultBaseFee`|`uint120`|The initialization of default baseFees for all token addresses that have not (yet) been given defaults|
|`_defaultVariableFee`|`uint120`|The initialization of default variableFees for all token addresses that have not (yet) been given defaults|
|`_networkTokenBaseFee`|`uint120`|The initialization of default baseFees for the network's token|
|`_networkTokenVariableFee`|`uint120`|The initialization of default variableFees for the network's token|


### setDefaultFees

*Function to set baseline base and variable fees across all collections without specified defaults*

*Only callable by contract owner, an address managed by Station*


```solidity
function setDefaultFees(uint120 baseFee, uint120 variableFee) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseFee`|`uint120`|The new baseFee to apply as default|
|`variableFee`|`uint120`|The new variableFee to apply as default|


### setTokenFees

*Function to set base and variable fees for a specific token*

*Only callable by contract owner, an address managed by Station*


```solidity
function setTokenFees(address token, uint120 baseFee, uint120 variableFee) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token for which to set new base and variable fees|
|`baseFee`|`uint120`|The new baseFee to apply to the token|
|`variableFee`|`uint120`|The new variableFee to apply to the token|


### removeTokenFees

*Function to remove base and variable fees for a specific token*

*Only callable by contract owner, an address managed by Station*


```solidity
function removeTokenFees(address token) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token for which to remove fees|


### setCollectionFees

*Function to set override base and variable fees on a per-collection basis*


```solidity
function setCollectionFees(address collection, address token, uint120 baseFee, uint120 variableFee)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection for which to set override fees|
|`token`|`address`|The token for which to set new base and variable fees|
|`baseFee`|`uint120`|The new baseFee to apply to the collection and token|
|`variableFee`|`uint120`|The new variableFee to apply to the collection and token|


### removeCollectionFees

*Function to remove base and variable fees for a specific token*

*Only callable by contract owner, an address managed by Station*


```solidity
function removeCollectionFees(address collection, address token) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection for which to remove fees|
|`token`|`address`|The token for which to remove fees|


### getFeeTotals

*Function to get collection fees*


```solidity
function getFeeTotals(address collection, address paymentToken, address, uint256 quantity, uint256 unitPrice)
    external
    view
    returns (uint256 feeTotal);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection whose fees will be read, including checks for client-specific fee discounts|
|`paymentToken`|`address`|The ERC20 token address used to pay fees. Will use base currency (ETH, MATIC, etc) when == address(0)|
|`<none>`|`address`||
|`quantity`|`uint256`|The amount of tokens for which to compute total baseFee|
|`unitPrice`|`uint256`|The price of each token, used to compute subtotal on which to apply variableFee|


### getDefaultFees

*Function to get baseline fees for all tokens*


```solidity
function getDefaultFees() public view returns (Fees memory fees);
```

### getTokenFees

*Function to get default fees for a token if they have been set*


```solidity
function getTokenFees(address token) public view returns (Fees memory fees);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token address to query against tokenFees mapping|


### getCollectionFees

*Function to get override fees for a collection and token if they have been set*


```solidity
function getCollectionFees(address collection, address token) public view returns (Fees memory fees);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection address to query against collectionFees mapping|
|`token`|`address`|The token address to query against collectionFees mapping|


### getFees

*Function to evaluate whether override fees have been set for a specific collection
and whether default fees have been set for the given token*


```solidity
function getFees(address _collection, address _token) public view returns (Fees memory fees);
```

### calculateFees

*Function to calculate fees using base and variable fee structures, agnostic to ETH or ERC20 values*


```solidity
function calculateFees(uint256 baseFee, uint256 variableFee, uint256 quantity, uint256 unitPrice)
    public
    pure
    returns (uint256 baseFeeTotal, uint256 variableFeeTotal);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseFee`|`uint256`|The base fee denominated either in ETH or ERC20 tokens|
|`variableFee`|`uint256`|The variable fee denominated either in ETH or ERC20 tokens|
|`quantity`|`uint256`|The number of tokens being minted|
|`unitPrice`|`uint256`|The price per unit of tokens being minted|


## Events
### DefaultFeesUpdated

```solidity
event DefaultFeesUpdated(Fees fees);
```

### TokenFeesUpdated

```solidity
event TokenFeesUpdated(address indexed token, Fees fees);
```

### CollectionFeesUpdated

```solidity
event CollectionFeesUpdated(address indexed collection, address indexed token, Fees fees);
```

## Errors
### FeesNotSet

```solidity
error FeesNotSet();
```

## Structs
### Fees
*Struct of fee data, including FeeSetting enum and both base and variable fees, all packed into 1 slot
Since `type(uint120).max` ~= 1.3e36, it suffices for fees of up to 1.3e18 ETH or ERC20 tokens, far beyond realistic scenarios.*


```solidity
struct Fees {
    bool exist;
    uint120 baseFee;
    uint120 variableFee;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`exist`|`bool`|boolean indicating whether the fee values exist|
|`baseFee`|`uint120`|The flat fee charged by Station Network on a per item basis|
|`variableFee`|`uint120`|The variable fee (in BPS) charged by Station Network on volume basis Accounts for each item's cost and total amount of items|

