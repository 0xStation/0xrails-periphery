# IERC20
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/ERC20/interface/IERC20.sol)


## Functions
### name


```solidity
function name() external view returns (string memory);
```

### symbol


```solidity
function symbol() external view returns (string memory);
```

### decimals


```solidity
function decimals() external view returns (uint8);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address account) external view returns (uint256);
```

### allowance


```solidity
function allowance(address owner, address spender) external view returns (uint256);
```

### transfer


```solidity
function transfer(address to, uint256 value) external returns (bool);
```

### approve


```solidity
function approve(address spender, uint256 value) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool);
```

## Events
### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value);
```

## Errors
### ERC20InsufficientBalance

```solidity
error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
```

### ERC20InvalidSender

```solidity
error ERC20InvalidSender(address sender);
```

### ERC20InvalidReceiver

```solidity
error ERC20InvalidReceiver(address receiver);
```

### ERC20InsufficientAllowance

```solidity
error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
```

### ERC20InvalidApprover

```solidity
error ERC20InvalidApprover(address approver);
```

### ERC20InvalidSpender

```solidity
error ERC20InvalidSpender(address spender);
```

### ERC20FailedDecreaseAllowance

```solidity
error ERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);
```

