# AccountProxy
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/lib/ERC6551AccountGroup/AccountProxy.sol)

**Inherits:**
Proxy, ERC1967Upgrade, [IERC6551AccountInitializer](/src/lib/ERC6551AccountGroup/interface/IERC6551AccountInitializer.sol/interface.IERC6551AccountInitializer.md)

Global Account Proxy to establish if an ERC6551 Account is using the Account Group pattern.
This contract is meant to be a permissionless singleton.


## Functions
### initializeAccount

*should we enforceme that this function can only be delegatecall'ed?*


```solidity
function initializeAccount(address, bytes memory) external payable;
```

### _implementation


```solidity
function _implementation() internal view virtual override returns (address);
```

