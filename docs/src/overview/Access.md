# Ownable, Access and Permissions

All but the most plutocratic of social organizations require an implementation of permissioning and access control. The same goes for any smart contract system, which must strictly define who may perform sensitive operations such as minting, burning, or upgrading.

The Access layer is responsible for establishing intuitive patterns to regulate permissions. These permissions range from expanding use of core operations, intertwining with the Module layer, to authorizing who can make swaps to the proxy implementation or modular contracts.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/9b322c24-c787-42a2-be0e-e63905872d82.png">

Our experience has landed us on a 3-tier pattern for access control:

  1. Permissions: flexible granting of operation control to any account
  2. Admins: a special permission that grants all other permissions automatically
  3. Owner: a singularly-held control that can do anything and administers itself

### Automation

One of the main benefits GroupOS offers is automation of an organization's workings. Permissions are a central part of group automation by delegating time-consuming actions such as payroll to smart contracts, effectively saving man-hours by automatically performing duties pre-defined in code.

## The 0xRails Ownable Module

At the top of the tiers is a singular owner which do everything an admin can except it cannot be changed by admins. This is highest permission possible in the framework and accordingly is meant to be seldom used or transferred and should be owned by a secure smart contract like a Safe.

Ownership can be transfered only in a two-step process that provides higher confidence that the receiving address has the ability to execute the required calls and reduces the risk of getting locked out with an incorrect destination address.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Ownable} from "groupos/lib/0xrails/src/access/ownable/Ownable.sol";

contract Pwn is Ownable {

    /// @dev Owner address is implemented using the `Ownable` contract's function
    function owner() public view override returns (address) {
        return Ownable.owner();
    }
}
```

The Ownable module can also be extended by overriding the `owner()` function, such as to enable ERC6551 tokenbound accounts. [GroupOS also provides an ERC6551 account implementation doing exactly that!](../0xrails/src/cores/ERC721Account/ERC721AccountRails.sol/contract.ERC721AccountRails.md)

#### Security note

Depending on security needs of the organization's contract system, the owner address can be an EOA, a smart contract account, or a multisig. Choose between these carefully, as a single private key could easily be compromised by a sufficiently motivated attacker. Bear in mind that his or her sufficient motivation is directly tied to the potential windfall or payout of obtaining the private key.

## Permissions and Access

From the previous document, you may remember that GroupOS Mint Controllers can be granted the permission to mint tokens. This is achieved when token collections that inherit `Rails` call the `addPermission(mintOperation, controllerAddress)` function with the mint operation and the controller's address.

Minting is not the only fine-grained permission available, however. Addresses can be given permission to mint, burn, transfer, update settings, or perform arbitrary calls. There are also admin permissions and options to perform these duties via "permit", or ECDSA signature.

At this point, one question that might come to mind is: "What is the difference between the Permissions and Access modules?" To answer this, here's a quick breakdown:

  - Permissions
    - Base layer of operation + address permissions
    - Does not include `Ownable`
    - Verification using `hasPermission()` is explicitly restricted to the permission provided
  - Access
    - Inherits Permissions base layer and extends it further
    - Includes `Ownable`
    - Overrides `hasPermission()` with a 3-tiered hierarchy where owners and admins pass verification for all permissions

## Admins

Admins receive a special permission that grant all other permissions automatically. As a cost and time savings for contract managers, the ability to create a role that inherits all permissions proves empirically convenient. Given the high authority of such a permission, it should be granted with intention.

Admins are allowed to set and remove all of the modular components of the framework in addition to whatever operations are native to the wrapped primitive (e.g. mint/burn/transfer token). Note that this also includes the ability to add or remove other admins.

### 0xRails Operations

Permissions enable flexible granting of operation control to any account. A permission is uniquely identified by the combination of an account address and an operation, which is the first 8 bytes of the hash of its unique string (e.g. bytes8(keccak256("MINT"))). Accounts can hold many permissions and an operation can be permitted to many accounts simultaneously. When these contracts are called to execute an operation, they will check that the msg.sender owns the appropriate permission.

At the base of the GroupOS access control system lies a set of 8-byte operations, which are defined [within 0xRails::Operations.sol](../0xrails/src/lib/Operations.sol/library.Operations.md)

```solidity
library Operations {
    bytes8 constant ADMIN = 0xfd45ddde6135ec42; // hashOperation("ADMIN");
    bytes8 constant MINT = 0x38381131ea27ecba; // hashOperation("MINT");
    bytes8 constant BURN = 0xf951edb3fd4a16a3; // hashOperation("BURN");
    bytes8 constant TRANSFER = 0x5cc15eb80ba37777; // hashOperation("TRANSFER");
    bytes8 constant METADATA = 0x0e5de49ee56c0bd3; // hashOperation("METADATA");
    bytes8 constant PERMISSIONS = 0x96bbcfa480f6f1a8; // hashOperation("PERMISSIONS");
    // ... et al
}
```

As you can infer, these permissions could represent very high levels of authority in an organizations hierarchy depending on the implementation.

To enable an 8-byte operation on a specific address, it is combined with an address to provide a very granular level of permissioning. To help developers understand the technicals of how this works, a rundown is discussed in-depth at [the bottom of this document](#permission-packing). It is however not necessary to understand the low-level bitpacking for developers who want to use the permissions system.

### Permission Packing

GroupOS permissions comprise a single 32-byte EVM word containing an address and 8-byte operation. This is achieved using a packing function within [PermissionsStorage](../0xrails/src/access/permissions/PermissionsStorage.sol/library.PermissionsStorage.md) called `_packKey()`. 

For example, here is a rundown demonstrating the packing mechanic. Let's say we want to pack the admin operation defined in Operations.sol with the maximum address value, ie:

```_packKey(adminOp, address(type(uint160).max))```

First, the address is left-packed by typecasting to uint256: 

```bytes32 addressToUint == 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff```

Then, we bitwise left-shift by 64 bits, ie 8 bytes (which in hex is 16 digits): 

```bytes32 leftShift64 == 0x00000000ffffffffffffffffffffffffffffffffffffffff0000000000000000```

Following that we left-pack the admin operation, which is `0xdf8b4c520ffe197c`, by typecasting it to a uint256:

```bytes32 leftPackedOp == 0x000000000000000000000000000000000000000000000000df8b4c520ffe197c```

Finally, we bitwise or the packed operation against the packed + shifted address: 

```bytes32 packedKey == 0x00000000ffffffffffffffffffffffffffffffffffffffffdf8b4c520ffe197c```

This final `packedKey` value above is what GroupOS reads from to understand which addresses have been granted permission to perform a protected operation.
