# AccountGroup
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/implementation/AccountGroup.sol)

**Inherits:**
IERC6551AccountGroup, [IAccountGroup](/src/accountGroup/interface/IAccountGroup.sol/interface.IAccountGroup.md), UUPSUpgradeable, Access, Initializable, Ownable


## Functions
### initialize


```solidity
function initialize(address owner_) external initializer;
```

### getAccountInitializer


```solidity
function getAccountInitializer(address account) external view returns (address);
```

### getDefaultAccountInitializer


```solidity
function getDefaultAccountInitializer() external view returns (address);
```

### getDefaultAccountImplementation


```solidity
function getDefaultAccountImplementation() external view returns (address defaultImpl);
```

### checkValidAccountUpgrade


```solidity
function checkValidAccountUpgrade(address sender, address account, address implementation) external view;
```

### setDefaultAccountInitializer


```solidity
function setDefaultAccountInitializer(address initializer) external onlyOwner;
```

### setAccountInitializer


```solidity
function setAccountInitializer(uint64 subgroupId, address initializer) public;
```

### setDefaultAccountImplementation


```solidity
function setDefaultAccountImplementation(address implementation) external onlyOwner;
```

### owner

*Owner address is implemented using the `Ownable` contract's function*


```solidity
function owner() public view override(Access, Ownable) returns (address);
```

### _checkCanUpdateSubgroup


```solidity
function _checkCanUpdateSubgroup(uint64) internal view;
```

### _checkCanUpdatePermissions

*Restrict Permissions write access to the `Operations.PERMISSIONS` permission*


```solidity
function _checkCanUpdatePermissions() internal view override;
```

### _authorizeUpgrade

*Only the `owner` possesses UUPS upgrade rights*


```solidity
function _authorizeUpgrade(address) internal view override;
```

