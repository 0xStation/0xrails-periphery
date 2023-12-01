# Smart Accounts

An account is the atomic unit of a network: a player of games, a member of a DAO, an users of a protocol.

GroupOS’s Accounts are ERC-6551 and ERC-4337 compliant smart contract wallets, offering full programmability and extensibility.

We provide out-of-the-box toolkit to gaslessly onboard and activate users to applications.

## Account Abstraction: ERC4337

[ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) is a new standard built on top of the EVM that enhances smart contract wallets on Ethereum-based blockchains. Commonly referred to as “Account Abstraction,” ERC-4337 allows developers to create customized and embedded experiences that eliminates the dependencies on EOAs to initiate transactions and pay for gas. 

In short, ERC-4337 makes smart contract wallets programmable. Developers can integrate wallet functionality into their user interfaces using these APIs, allowing them to experiment and customize the wallet experience for their applications.

## Tokenbound Accounts: ERC6551

[ERC-6551](https://eips.ethereum.org/EIPS/eip-6551), token-bound accounts (TBAs), builds upon the ERC-721 standard by introducing smart contract capabilities to NFTs. Every NFT will be able to own ETH and other ERC20s, 721, 1155 tokens, and be associated with onchain attestations. Using digital outfits and items, the standard can power new use cases like NFT loyalty programs, PFPs as on-chain identities, and new game mechanics.

## ERC4337 🤝 ERC6551
We recognize the genre-defining possibility when the two standards are combined. The new paradigm can change the way users onboard and engage onchain. While ERC-6551 creates a visual representation and a unifying source of truth that fosters a sense of psychological ownership, account abstraction gives dApp developers and networks flexibility to automate operations and rewards with smart contracts programmatically.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/0ff575f3-1e21-422c-b93d-551f50d73db8.png">

## GroupOS Account Abstraction Contracts

GroupOS has built out contracts to suit every flavor of account abstraction that an organization might want. These boilerplates can be found in the [0xRails `cores` directory](https://github.com/0xStation/0xrails/tree/713468f3791af6e2a9a0542da50055ab9270fe22/src/cores/account).

### Account.sol

The base contract used for all GroupOS account infrastructure is called `Account`, which defines the most basic logic and state common to all smart contract account and AA use cases. 

To be more specific, this contract ensures all GroupOS accounts which inherit from this base class are recognized as receivers of ERC721 and ERC1155 `safeTransfer()`.  This contract is also where the immutable ERC4337 `entryPoint` contract address is declared, as well as the GroupOS validation flag which opens the door to [modular and customizable validation schemes](../overview/Validator.md).

### AccountRails

This contract inherits from `Account` and further extends functionality to include `Rails` as well as ERC1271 smart contract signatures and options for GroupOS modular validation. [Signature validation is discussed in-depth in a later document](../overview/Validator.md). Due to its richness of features and support for all relevant ERC standards that surround onchain smart contract wallets and account abstraction, `AccountRails` is the recommended parent contract to use for most use cases.

### ERC721Account

GroupOS provides an account implementation specifically designed for [ERC-6551](https://eips.ethereum.org/EIPS/eip-6551) but is built with AccountRails, therefore also supporting ERC4337, ERC1271, and customizable validation. This flavor of AccountRails is meant to be bound to an NFT, meaning the owner of the NFT also owns the account. 

The nuances of ERC6551 are beyond the scope of this document, but in short `ERC721Account` lives onchain as a singleton implementation that account proxy contracts point to, meaning it is also upgradeable! 

It's worth noting that due to the inclusion of `chainId` in ERC6551, upgradeability in cross chain scenarios must be handled in a permissioned way- GroupOS provides a solution for this using the AccountGroup contracts.

### AccountGroup

The `AccountGroup` contract enables social coordination of abstract accounts as a unit, ie a "group". For organizations that desire the ability to coordinate configurations for all their users, this contract allows groups to configure a default account implementation as well as a default initializer contract.

These group-wide settings give organizations several benefits, notably:

  - Secure and consistent default account behavior, as all user accounts point to the same implementation at deployment
  - Secure and predictable account behavior upon upgrade, as Account Groups may limit upgrades to whitelisted implementations
  - Protection from account initialization frontrunning (a problem inherent to proxy contracts)
  - Protection from account address sniping, a form of onchain frontrunning

The last point is worth discussing as it is an open question during the current stage of the ERC6551 spec.

#### Address Sniping

As ERC6551 is permissionless by design, a griefing vector is available where adversaries can deploy tokenbound accounts using NFTs that they do not own. For example, let's say I own a Moonbirds NFT, tokenId #9535. Because ERC6551 is permissionless, anyone may create tokenbound accounts that are bound to my Moonbird!

This is not necessarily an issue, until the account implementation address that I actually want to use is known. However, since there are not many account implementation offerings, that information is unfortunately expected to be public for most users. As a result, malicious actors can predetermine the address(es) that my token would be associated with, and preemptively take control of those accounts.

Further, ERC6551 tokenbound accounts are ERC1167 minimal proxies, which are not upgradeable by default. To enable upgradeability, GroupOS makes use of an `AccountProxy`, the address of which is public. As a result, the need for protection against address sniping became clear.

GroupOS protects against this and other vectors at the `AccountGroup` level by enforcing account creation and initialization through modular controller contracts.

## GroupOS Account Controllers

Similar to the controllers designed for modularized token minting, GroupOS features controllers that serve the specialized role of initializing smart accounts. The need for initialization arises out of the fact that smart contract accounts are proxies, which point to a singleton implementation. Using lightweight proxies for each account translates to cheap deployment costs and allows users to individually upgrade or groups to collectively upgrade account implementations.

### PermissionGatedInitializer

To protect against unauthorized initialization, GroupOS provides a default initializer contract called the `PermissionGatedInitializer` which account groups may use. Groups may also opt for a custom initializer that is specific to their group should they deem that more appropriate.

The `PermissionGatedInitializer` simply enforces that the entity creating the ERC6551 tokenbound account possesses the Rails permission for `Operations.INITIALIZE_ACCOUNT`, which must have previously been granted on the AccountGroup contract.

### InitializeAccountController

### MintCreateInitializeController

