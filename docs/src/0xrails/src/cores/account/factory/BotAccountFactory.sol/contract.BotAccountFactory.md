# BotAccountFactory
[Git Source](https://github.com/0xStation/0xrails/blob/7b2d3363f0d5023623fd16114b60a38cf52ce246/src/cores/account/factory/BotAccountFactory.sol)

**Inherits:**
[Initializable](/src/lib/initializable/Initializable.sol/abstract.Initializable.md), UUPSUpgradeable, [AccountFactory](/src/cores/account/factory/AccountFactory.sol/abstract.AccountFactory.md)

**Author:**
👦🏻👦🏻.eth

*This BotAccountFactory deploys a BotAccount using `CREATE2` to a counterfactual address.*


## Functions
### constructor


```solidity
constructor() Initializable;
```

### initialize


```solidity
function initialize(address _botAccountImpl, address _owner) external initializer;
```

### createBotAccount

*Function to deploy a new Account using the `CREATE2` opcode*


```solidity
function createBotAccount(
    bytes32 salt,
    address botAccountOwner,
    address callPermitValidator,
    address[] calldata turnkeys
) external returns (address newAccount);
```

### simulateCreateBotAccount

*Function to return a simulated address for BotAccount creation using a given salt*


```solidity
function simulateCreateBotAccount(bytes32 salt) public view returns (address);
```

### _createBotAccount


```solidity
function _createBotAccount(
    bytes32 _salt,
    address _botAccountOwner,
    address _callPermitValidator,
    address[] memory _turnkeys
) internal returns (address payable newBotAccount);
```

### _authorizeUpgrade

*Only the owner may authorize a UUPS upgrade*


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

