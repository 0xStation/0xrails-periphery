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

As ERC6551 is permissionless by design, a griefing vector is available where adversaries can deploy tokenbound accounts using NFTs that they do not own.

For example, let's say I own a **Moonbirds NFT, tokenId #9535**. Because ERC6551 is permissionless, anyone may create tokenbound accounts that are bound to my Moonbird!

This is not necessarily an issue, until the account implementation address that I actually want to use is known. However, since there are not many account implementation offerings, that information is unfortunately expected to be public for most users. As a result, malicious actors can predetermine the address(es) that my token would be associated with, and preemptively take control of those accounts!

Further, ERC6551 tokenbound accounts are ERC1167 minimal proxies, which are not upgradeable by default. To enable upgradeability, GroupOS makes use of an `AccountProxy`, the address of which is public. As a result, the need for protection against address sniping became clear.

GroupOS protects against this and other vectors at the `AccountGroup` level by enforcing account creation and initialization through modular controller contracts.

## GroupOS Account Controllers

Similar to the controllers designed for modularized token minting, GroupOS features controllers that serve the specialized role of initializing smart accounts. The need for initialization arises out of the fact that smart contract accounts are proxies, which point to a singleton implementation. Using lightweight proxies for each account translates to cheap deployment costs and allows users to individually upgrade or groups to collectively upgrade account implementations.

### PermissionGatedInitializer

To protect against unauthorized initialization, GroupOS provides a default initializer contract called the `PermissionGatedInitializer` which account groups may use. Groups may also opt for a custom initializer that is specific to their group should they deem that more appropriate.

The `PermissionGatedInitializer` simply enforces that the entity creating the ERC6551 tokenbound account possesses the Rails permission for `Operations.INITIALIZE_ACCOUNT`, which must have previously been granted on the AccountGroup contract.

```solidity
    function _authenticateInitialization(address, bytes memory initData)
        internal
        view
        override
        returns (bytes memory)
    {
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams();
        // Verify entity calling the 6551 Account (msg.sender) has INITIALIZE_ACCOUNT permission from Account Group
        IPermissions(params.accountGroup).checkPermission(Operations.INITIALIZE_ACCOUNT, msg.sender);

        return initData;
    }
```

### InitializeAccountController

Since ERC6551 accounts are proxies, they cannot use the traditional solidity `constructor()` function and must instead be initialized. To protect against initialization frontrunning (which is a possibility with any proxy contract) GroupOS provides the `InitializeAccountController` which bundles creation and initialization in the same transaction. 

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
    ) external usePermits(_encodePermitContext(salt)) returns (address account) {
        // deploy account
        account = IERC6551Registry(registry).createAccount(accountProxy, salt, chainId, tokenContract, tokenId);
        // initialize account
        IERC6551AccountInitializer(account).initializeAccount(accountImpl, initData);
    }
```

This leaves no opportunity for an adversary to step in after account creation and maliciously initialize the account.

### MintCreateInitializeController

GroupOS also provides a `MintCreateInitializeController` which serves all the same purposes as the `InitializeAccountController` but also mints the ERC721Rails token that owns the ERC6551 account in the same transaction. In short, calling `MintCreateInitializeController::mintAndCreateAccount()`:

  - Mints a new tokenId on the provided ERC721Rails collection
  - Creates an ERC6551 tokenbound account owned by the above ERC721Rails NFT
  - Initializes the tokenbound account with the provided data to protect against frontrunning