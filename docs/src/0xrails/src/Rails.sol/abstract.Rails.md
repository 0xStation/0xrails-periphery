# Rails
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/Rails.sol)

**Inherits:**
[Access](/src/access/Access.sol/abstract.Access.md), [Guards](/src/guard/Guards.sol/abstract.Guards.md), [Extensions](/src/extension/Extensions.sol/abstract.Extensions.md), [SupportsInterface](/src/lib/ERC165/SupportsInterface.sol/abstract.SupportsInterface.md), [Execute](/src/lib/Execute.sol/abstract.Execute.md), Multicall, UUPSUpgradeable

A Solidity framework for creating complex and evolving onchain structures.
All Rails-inherited contracts receive a batteries-included contract development kit.


## Functions
### contractURI

*Function to return the contractURI for child contracts inheriting this one
Unimplemented to abstract away this functionality and render it opt-in*


```solidity
function contractURI() public view virtual returns (string memory uri);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The returned contractURI string|


### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(Access, Guards, Extensions, SupportsInterface, Execute)
    returns (bool);
```

### _beforeExecuteCall

*Hook to perform pre-call checks and return guard information.*


```solidity
function _beforeExecuteCall(address to, uint256 value, bytes calldata data)
    internal
    virtual
    override
    returns (address guard, bytes memory checkBeforeData);
```

### _afterExecuteCall

*Hook to perform post-call checks.*


```solidity
function _afterExecuteCall(address guard, bytes memory checkBeforeData, bytes memory executeData)
    internal
    virtual
    override;
```

