# AccountFactory
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/factory/AccountFactory.sol)

**Inherits:**
[Ownable](/src/access/ownable/Ownable.sol/abstract.Ownable.md), [IAccountFactory](/src/cores/account/factory/interface/IAccountFactory.sol/interface.IAccountFactory.md)

**Author:**
👦🏻👦🏻.eth

*This AccountFactory contract uses the `CREATE2` opcode to deterministically
deploy a new ERC1271 and ERC4337 compliant Account to a counterfactual address.
Deployments can be precomputed using the deployer address, random salt, and
a keccak hash of the contract's creation code*


## Functions
### setAccountImpl

*Function to set the implementation address whose logic will be used by deployed account proxies*


```solidity
function setAccountImpl(address newAccountImpl) external onlyOwner;
```

### getAccountImpl

*Function to get the implementation address whose logic is used by deployed account proxies*


```solidity
function getAccountImpl() public view returns (address);
```

### simulateCreate2

*Function to simulate a `CREATE2` deployment using a given salt and desired AccountType*


```solidity
function simulateCreate2(bytes32 salt, bytes32 creationCodeHash) public view returns (address);
```

### _updateAccountImpl


```solidity
function _updateAccountImpl(address _newAccountImpl) internal;
```

### _simulateCreate2


```solidity
function _simulateCreate2(bytes32 _salt, bytes32 _creationCodeHash)
    internal
    view
    returns (address simulatedDeploymentAddress);
```

