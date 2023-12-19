# ERC20
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC20/ERC20.sol)

**Inherits:**
[IERC20](/src/cores/ERC20/interface/IERC20.sol/interface.IERC20.md)

*Rewrite of OpenZeppelin's ERC20, but with ERC7201 namespaced storage layout and guard hooks*


## Functions
### decimals


```solidity
function decimals() public view virtual returns (uint8);
```

### totalSupply


```solidity
function totalSupply() public view virtual returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address account) public view virtual returns (uint256);
```

### transfer


```solidity
function transfer(address to, uint256 value) public virtual returns (bool);
```

### allowance


```solidity
function allowance(address owner, address spender) public view virtual returns (uint256);
```

### approve


```solidity
function approve(address spender, uint256 value) public virtual returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
```

### increaseAllowance


```solidity
function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool);
```

### decreaseAllowance


```solidity
function decreaseAllowance(address spender, uint256 requestedDecrease) public virtual returns (bool);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```

### _transfer


```solidity
function _transfer(address from, address to, uint256 value) internal;
```

### _update

*Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from` (or `to`) is
the zero address. All customizations to transfers, mints, and burns should be done by overriding this function.
Emits a {Transfer} event.*


```solidity
function _update(address from, address to, uint256 value) internal virtual;
```

### _mint


```solidity
function _mint(address account, uint256 value) internal;
```

### _burn


```solidity
function _burn(address account, uint256 value) internal;
```

### _approve


```solidity
function _approve(address owner, address spender, uint256 value) internal virtual;
```

### _approve

*Alternative version of {_approve} with an optional flag that can enable or disable the Approval event.
By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
`_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
`Approval` event during `transferFrom` operations.
Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to true
using the following override:
```
function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
super._approve(owner, spender, value, true);
}
```
Requirements are the same as {_approve}.*


```solidity
function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual;
```

### _spendAllowance


```solidity
function _spendAllowance(address owner, address spender, uint256 value) internal virtual;
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    virtual
    returns (address guard, bytes memory beforeCheckData);
```

### _afterTokenTransfer


```solidity
function _afterTokenTransfer(address guard, bytes memory checkBeforeData) internal virtual;
```

