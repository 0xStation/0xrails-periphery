# PermitMintController
[Git Source](https://github.com/0xStation/groupos/blob/a8023d340c65e0d686ded288134361dc4f500ad5/src/token/controller/PermitMintController.sol)

**Inherits:**
[PermitController](/src/lib/module/PermitController.sol/abstract.PermitController.md), [SetupController](/src/lib/module/SetupController.sol/abstract.SetupController.md), Multicall

**Author:**
frog (@0xmcg), 👦🏻👦🏻.eth

As this controller is entirely fee-less via enforced permits, it does not make use
of the FeeManager (which charges a baseline default mint fee) nor the permit controller mapping

*Mint tokens entirely for free with signature-based authentication*

*Supports all three 0xRails token standard implementations: ERC20, ERC721, ERC1155*


## Functions
### mintToERC20

Can only be called successfully with data signed by a key explicitly granted permission
by an authorized address on the target collection

*Function to mint ERC20 collection tokens to a specified recipient*


```solidity
function mintToERC20(address collection, address recipient, uint256 amount)
    external
    payable
    usePermits(_encodePermitContext(collection));
```

### mintToERC721

Can only be called successfully with data signed by a key explicitly granted permission
by an authorized address on the target collection

*Function to mint ERC721 collection tokens to a specified recipient*


```solidity
function mintToERC721(address collection, address recipient, uint256 amount)
    external
    payable
    usePermits(_encodePermitContext(collection));
```

### mintToERC1155

Can only be called successfully with data signed by a key explicitly granted permission
by an authorized address on the target collection

*Function to mint ERC20 collection tokens to a specified recipient*


```solidity
function mintToERC1155(address collection, address recipient, uint256 tokenId, uint256 amount)
    external
    payable
    usePermits(_encodePermitContext(collection));
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
function requirePermits(bytes memory) public pure override returns (bool);
```

