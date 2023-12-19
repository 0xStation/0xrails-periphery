# InitializeAccountController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/accountGroup/module/InitializeAccountController.sol)

**Inherits:**
[PermitController](/src/lib/module/PermitController.sol/abstract.PermitController.md)

Bundle account creation and initialization into one transaction


## Functions
### createAndInitializeAccount

Core function to bundle together account deployment and initialization

*usePermits is added to allow dynamic permissioning via direct call or signature permit from
an entity with INITIALIZE_ACCOUNT_PERMIT permission on the account group*


```solidity
function createAndInitializeAccount(
    address registry,
    address accountProxy,
    bytes32 salt,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId,
    address accountImpl,
    bytes memory initData
) external usePermits(_encodePermitContext(salt)) returns (address account);
```

### _encodePermitContext


```solidity
function _encodePermitContext(bytes32 salt) internal pure returns (bytes memory context);
```

### _decodePermitContext


```solidity
function _decodePermitContext(bytes memory context) internal pure returns (address accountGroup);
```

### requirePermits

If sender has INITIALIZE_ACCOUNT_PERMIT permission on account group, then skip permit process


```solidity
function requirePermits(bytes memory context) public view override returns (bool);
```

### signerCanPermit

If a permit is expected, then validate the signer has INITIALIZE_ACCOUNT_PERMIT permission


```solidity
function signerCanPermit(address signer, bytes memory context) public view override returns (bool);
```

## Errors
### InvalidPermission

```solidity
error InvalidPermission();
```

