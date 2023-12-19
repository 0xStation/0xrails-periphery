# GroupOS Core Contracts 🧙

_A Solidity framework for creating complex and evolving onchain structures._

**GroupOS** is a Web3 toolkit to activate members, distribute rewards and measure growth by providing:

- _Flexibility_
  - Our infrastructure and developer tooling allows for maximal customizability in each step of the user journey. From proof-of-humanhood and KYC mechanisms to custom branding and front-end, we look to power application experiences in the background.
- _Attributability_
  - token networks need to be user-centric (members including both people and bots!) with access to data to understand engagement and activities.
- _Modularity_
  - Our developer kit fits seamlessly into and alongside existing workflows and applications. Developers can bring their existing contracts or create new ones with us.
- _Ease-of-use_
  - From our APIs/SDKs to our no-code dashboard, we seek beauty in simplicity and ease of use.

## Contract Architecture

<div style="text-align:center"><img src="https://github.com/0xStation/tokens-v1/assets/80549215/a68b8a19-4568-45a7-9d32-d5738409081e" width="400" ></div>

## Directory Tree

```
* = deployed contract

src
├── accountGroup
│   ├── implementation
│   │   ├── AccountGroup.sol*
│   │   └── AccountGroupStorage.sol
│   ├── initializer
│   │   └── PermissionGatedInitializer.sol*
│   ├── interface
│   │   └── IAccountGroup.sol
│   ├── lib
│   │   └── AccountGroupLib.sol
│   └── module
│       ├── InitializeAccountController.sol*
│       └── MintCreateInitializeController.sol*
├── factory
│   ├── ITokenFactory.sol
│   ├── TokenFactory.sol*
│   └── TokenFactoryStorage.sol
├── lib
│   ├── module
│   │   ├── ERC6551AccountController.sol
│   │   ├── FeeController.sol
│   │   ├── FeeManager.sol*
│   │   ├── PermitController.sol
│   │   └── SetupController.sol
│   └── NonceBitMap.sol
├── membership
│   ├── extensions
│   │   ├── NFTMetadataRouter
│   │   │   ├── INFTMetadata.sol
│   │   │   ├── NFTMetadataRouterExtension.sol*
│   │   │   └── NFTMetadataRouter.sol
│   │   └── PayoutAddress
│   │       ├── IPayoutAddress.sol
│   │       ├── PayoutAddressExtension.sol*
│   │       ├── PayoutAddress.sol
│   │       └── PayoutAddressStorage.sol
│   ├── guards
│   │   └── OnePerAddressGuard.sol*
│   └── modules
│       ├── FreeMintController.sol*
│       ├── GasCoinPurchaseController.sol*
│       └── StablecoinPurchaseController.sol*
├── metadataRouter
│   ├── IMetadataRouter.sol
│   ├── MetadataRouter.sol*
│   └── MetadataRouterStorage.sol
└── token
    └── controller
        └── GeneralFreeMintController.sol*
```

## Contributing

While GroupOS is in initial release, assistance on reviews for security and developer experience are most appreciated. In the meantime, please reach out directly via [Twitter DM](https://twitter.com/ilikesymmetry).

## License

Direct inquiries for using GroupOS in your own project via [Twitter DM](https://twitter.com/ilikesymmetry). GroupOS has recently completed a security audit by Sayfer Security. The audit report can be obtained by contacting us and will be published shortly.
