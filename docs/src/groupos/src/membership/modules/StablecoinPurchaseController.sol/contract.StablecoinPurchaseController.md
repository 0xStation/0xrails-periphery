# StablecoinPurchaseController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/membership/modules/StablecoinPurchaseController.sol)

**Inherits:**
[SetupController](/src/lib/module/SetupController.sol/abstract.SetupController.md), [PermitController](/src/lib/module/PermitController.sol/abstract.PermitController.md), [FeeController](/src/lib/module/FeeController.sol/abstract.FeeController.md), Pausable

**Author:**
symmetry (@symmtry69), frog (@0xmcg)

Mint membership tokens when users pay a fixed quantity of a stablecoin

*Storage is designed to minimize costs for accepting multiple stablecoins as
payment by packing all data into 1 slot. Updating the price for N stablecoins has
constant G(1) gas complexity. Additionally, it is guaranteed that all stablecoins
will use the same price value and can never get out of sync. Deploy one instance
of this module per currency, per chain (e.g. USD, EUR, BTC).*


## State Variables
### decimals
*Decimals of precision for this module's currency*


```solidity
uint8 public immutable decimals;
```


### currency

```solidity
string public currency;
```


### keyCounter
This counter supports up to 255 stablecoin address keys in a bytes16 map

*The total number of keys currently in bitmap, initialized to the number of default addresses in StablecoinRegistry*


```solidity
uint8 public keyCounter;
```


### _keyOf
*Mapping of stablecoin address => associated key in bitmap*


```solidity
mapping(address => uint8) internal _keyOf;
```


### _stablecoinOf
*Mapping of bitmap key => stablecoin address*


```solidity
mapping(uint8 => address) internal _stablecoinOf;
```


### _parameters
*Mapping of each collection => mint parameters configuration*


```solidity
mapping(address => Parameters) internal _parameters;
```


### _disablePermits
*collection => permits disabled, permits are enabled by default*


```solidity
mapping(address => bool) internal _disablePermits;
```


## Functions
### constructor


```solidity
constructor(address _owner, address _feeManager, uint8 _decimals, string memory _currency)
    PermitController
    FeeController(_owner, _feeManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The owner of this contract|
|`_feeManager`|`address`|The FeeManager module's address|
|`_decimals`|`uint8`|The decimals value for this module's supported stablecoin payments|
|`_currency`|`string`|The type of currency managed by this module|


### register

*Function to register new stablecoins when requested by clients*


```solidity
function register(address stablecoin) external onlyOwner returns (uint8 newKey);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stablecoin`|`address`|The stablecoin token contract to register in the bitmap|


### _register


```solidity
function _register(address stablecoin) internal returns (uint8 newKey);
```

### keyOf

*Function to check the bitmap key for a stablecoin*


```solidity
function keyOf(address stablecoin) public view returns (uint8 key);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stablecoin`|`address`|The stablecoin address to query against the _keyOf storage mapping|


### stablecoinOf

*Function to get the stablecoin contract address for a specific bitmap key*


```solidity
function stablecoinOf(uint8 key) public view returns (address stablecoin);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`uint8`|The bitmap key to query against the _stablecoinOf storage mapping|


### stablecoinOptions

*Function to get the entire set of stablecoins supported by this module*


```solidity
function stablecoinOptions() public view returns (address[] memory stablecoins);
```

### setUp

*Function to set up and configure a new collection's purchase prices and payment options*


```solidity
function setUp(address collection, uint128 price, address[] memory enabledCoins, bool enablePermits)
    public
    canSetUp(collection);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The new collection to configure|
|`price`|`uint128`|The price in a stablecoin currency for this collection's mints|
|`enabledCoins`|`address[]`|The stablecoin addresses to be supported for this collection's mints|
|`enablePermits`|`bool`|A boolean to represent whether this collection will repeal or support grant functionality|


### setUp

*note that this relies on the canSetUp modifier being used in the public function*


```solidity
function setUp(uint128 price, address[] memory enabledCoins, bool enablePermits) external;
```

### enabledCoinsOf

*Function to get the enabled stablecoins of a collection*


```solidity
function enabledCoinsOf(address collection) external view returns (address[] memory stablecoins);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection for which stablecoins are enabled|


### stablecoinEnabled

*Function to check if a specific stablecoin is enabled for a collection. Reverts for unregistered stablecoins.*


```solidity
function stablecoinEnabled(address collection, address stablecoin) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection to check against _collectionConfig storage mapping|
|`stablecoin`|`address`|The stablecoin being queried against the provided collection address|


### _stablecoinEnabled


```solidity
function _stablecoinEnabled(bytes16 enabledCoins, address stablecoin) internal view returns (bool);
```

### _enabledCoinsValue

*Internal function to process an array of stablecoin addresses into a packed 16 byte bitmap of their corresponding keys*


```solidity
function _enabledCoinsValue(address[] memory stablecoins) internal view returns (bytes16 value);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stablecoins`|`address[]`|The stablecoin addresses to process|


### _keyBitOf


```solidity
function _keyBitOf(address stablecoin) internal view returns (bytes16);
```

### priceOf

*Function to get the configuration of a collection, incl stablecoin price and enabled stablecoins*


```solidity
function priceOf(address collection) external view returns (uint128 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The collection to query against _parameters storage mapping|


### mintPriceToStablecoinAmount

*Function to handle decimal precision variation between stablecoin implementations*


```solidity
function mintPriceToStablecoinAmount(uint256 price, address stablecoin) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|The desired stablecoin price to be checked against ERC20 decimals() and formatted if needed|
|`stablecoin`|`address`|The stablecoin implementation to which to conform|


### mint

*Function to mint a single collection token to the caller, ie a user*


```solidity
function mint(address collection, address paymentCoin) external whenNotPaused;
```

### mintTo

*Function to mint a single collection token to a specified recipient*


```solidity
function mintTo(address collection, address paymentCoin, address recipient) external whenNotPaused;
```

### batchMint

returned tokenId range is inclusive

*Function to mint collection tokens in batches to the caller, ie a user*


```solidity
function batchMint(address collection, address paymentCoin, uint256 quantity) external whenNotPaused;
```

### batchMintTo

returned tokenId range is inclusive

*Function to mint collection tokens in batches to a specified recipient*


```solidity
function batchMintTo(address collection, address paymentCoin, address recipient, uint256 quantity)
    external
    whenNotPaused;
```

### _batchMint

returned tokenId range is inclusive

*Internal function to which all external user + client facing mint functions are routed.*


```solidity
function _batchMint(address collection, address paymentCoin, address recipient, uint256 quantity)
    internal
    usePermits(_encodePermitContext(collection));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The token collection to mint from|
|`paymentCoin`|`address`|The stablecoin address being used for payment|
|`recipient`|`address`|The recipient of successfully minted tokens|
|`quantity`|`uint256`|The quantity of tokens to mint|


### pause


```solidity
function pause() public onlyOwner;
```

### unpause


```solidity
function unpause() public onlyOwner;
```

### _encodePermitContext


```solidity
function _encodePermitContext(address collection) internal pure returns (bytes memory context);
```

### _decodePermitContext


```solidity
function _decodePermitContext(bytes memory context) internal pure returns (address collection);
```

### signerCanPermit


```solidity
function signerCanPermit(address signer, bytes memory context) public view override returns (bool);
```

### requirePermits


```solidity
function requirePermits(bytes memory context) public view override returns (bool);
```

## Events
### Register

```solidity
event Register(address indexed stablecoin, uint8 indexed key);
```

### SetUp
*Events share names but differ in parameters to differentiate them between controllers*


```solidity
event SetUp(address indexed collection, uint128 price, address[] enabledCoins, bool indexed enablePermits);
```

## Structs
### Parameters
*Struct of collection price data*


```solidity
struct Parameters {
    uint128 price;
    bytes16 enabledCoins;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint128`|The price in ERC20 tokens set for a collection's mint Max value of uint128 (~3.4e38) is several orders of magnitude larger than the current total supply of Ethereum (1.2e26 wei)|
|`enabledCoins`|`bytes16`|A bitmap of single byte keys that correspond to supported stablecoins|

