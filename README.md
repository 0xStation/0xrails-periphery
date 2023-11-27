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

## Onchain Deployments

### Addresses are consistent across networks

#### The following addresses are v1.3.0, currently deployed to Linea mainnet, Linea testnet, Sepolia, and Goerli. For other versions deployed to different networks, consult `deploys.json`

| Contract                           | Gas       | Address                                    |
| ---------------------------------- | --------- | ------------------------------------------ |
| StationFounderSafe Multisig Proxy  | 274,123   | 0x8667cde7a8De51ea1d0C8E215845E74c04192D09 |
| AdminGuard                         | 1,013,754 | 0xDB9A089A20D4b8cDef355ca474323b6C832D9776 |
| CallPermitValidator                | 770,771   | 0xedd397e2947f3c400db6f0b5914fb621838cfb72 |
| BotAccountImpl                     | 4,179,853 | 0x1b2477eee03a4aff7a0079dcffafd068a922feb0 |
| BotAccountProxy                    | 136,124   | 0xb23b79e466d8736f541354ab72d56f06ed0b7e5d |
| ERC721Rails                        | 4,717,748 | 0xb5764bd3ad21a58f723db04aeb97a428c7bdde2a |
| ERC20Rails                         | 3,879,187 | 0xa8f4f8ef600dd6ff538426fc206e8a1457d90d95 |
| ERC1155Rails                       | 4,410,740 | 0x053809dfdd2443616d324c93e1dfc6a2076f976b |
| TokenFactoryImpl                   | 2,087,959 | 0xd4b8c7ceaf8d7fc4b34b157f31be0d8e9e9022af |
| TokenFactoryProxy                  | 259,529   | 0x2c333bd1316ce1af9ebf017a595d6f8ab5f6bd1a |
| MetadataRouterImpl                 | 1,915,882 | 0x9dc652b502731d9a41fb60bcce9bc33b74619b4c |
| MetadataRouterProxy                | 336,187   | 0xd875345db38a113f3dd8f766f57cbbd2c4c2ab99 |
| OneAddressPerGuard                 | 426,313   | 0x5f00d3707f1e4183003e75d3e995b814fb8fabe6 |
| NFTMetadataRouterExtension         | 535,214   | 0x3cad50c2621a4da3a5199370ceb00d6055d29650 |
| PayoutAddressExtension             | 632,639   | 0x53ef68a35f9ae248f28584ab8e724896eb2d41c5 |
| FeeManager                         | 869,188   | 0x0af22fe98babe7b3dedc14ba3e0f33e9e63444f3 |
| ERC721FreeMintController           | 1,906,671 | 0x160e449bf97edbf5427717271bbfffd53e3f109d |
| ERC721GasCoinPurchaseController    | 2,013,611 | 0xb336c2c5568b310ec5774cb6c577280c14c4dac2 |
| ERC721StablecoinPurchaseController | 2,926,173 | 0x65c4a1a4627dff7d66b45b4775e13fe5194fd197 |
| PermitMintController               | 996,693   | 0x1bceecf6938f5dbcb551f526ad4a3f592ba15732 |
| PermissionGatedInitializer         | 318,755   | 0xd84e8ac29cb1e20e24ab1bafea36c16881d84856 |
| InitializeAccountController        | 961,478   | 0xfc85ba406338303d1a155364fa6dd5ad97c35f2a |
| MintCreateInitializeController     | 959,274   | 0x767a92675a01fbf1a33eb9b4c37e718a66d921cb |
| ERC721AccountRails                 | 4,117,521 | 0x509b531c8e979c85375370c0ba92ac44173c2d12 |
| AccountGroupImpl                   | 1,501,090 | 0x2cb1dc8b63c32f03c6f496207027e1aaf9a47c0c |
| AccountGroupProxy                  | 59,670    | 0x852517b7ffed0f98d714dd1787995aff4d6b1892 |
