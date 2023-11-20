# GroupOS Core Contracts 🧙

_A Solidity framework for creating complex and evolving onchain structures._

**GroupOS** is a Web3 toolkit to activate members, distribute rewards and measure growth by providing:

  - *Flexibility* 
    - Our infrastructure and developer tooling allows for maximal customizability in each step of the user journey. From proof-of-humanhood and KYC mechanisms to custom branding and front-end, we look to power application experiences in the background.
  - *Attributability* 
    - token networks need to be user-centric (members including both people and bots!) with access to data to understand engagement and activities.
  - *Modularity* 
    - Our developer kit fits seamlessly into and alongside existing workflows and applications. Developers can bring their existing contracts or create new ones with us.
  - *Ease-of-use*
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

Direct inquiries for using GroupOS in your own project via [Twitter DM](https://twitter.com/ilikesymmetry). Note that GroupOS is currently undergoing a security audit.

## Onchain Deployments
### Addresses are consistent across networks
#### The following addresses are v1.3.0, currently deployed to Linea mainnet, Linea testnet, Sepolia, and Goerli. For other versions deployed to different networks, consult `deploys.json`

| Contract | Gas | Address |
| --- | --- | --- |
| StationFounderSafe Multisig Proxy |  274,123 | 0x8667cde7a8De51ea1d0C8E215845E74c04192D09 | 
| AdminGuard | 1,013,754 | 0xDB9A089A20D4b8cDef355ca474323b6C832D9776 | 
| CallPermitValidator | 770,771 | 0x7278570a84bc86e26c0cf581276c8c2b9e12a284 | 
| BotAccountImpl | 4,179,853 | 0xf73c9bebe90d4e1e23e33d3d6b668b4eb5a34cac | 
| BotAccountProxy | 136,124 | 0x6de24d0389130fdacc54b9209696f6f7fcbeeee1 | 
| ERC721Rails | 4,717,748 | 0x585cc04541d2077cd02bbc1866e0b49b59499d1a | 
| ERC20Rails | 3,879,187 | 0xe8f8242acb4f05dcf03cefebee6d0b077c5aee78 | 
| ERC1155Rails | 4,410,740 | 0xeec5f1c40f76fd96de8a6222485179878ae818eb |  
| TokenFactoryImpl | 2,087,959 | 0x7ed278b15d58b8fc073e5453a354f9f3bcbad32e | 
| TokenFactoryProxy | 259,529 | 0xda32efd5a06a220707f7406e57056f97684ea405 | 
| MetadataRouterImpl | 1,915,882 | 0x407c8ae5a8298b0e7609e8fc6cf79da2a2380032 | 
| MetadataRouterProxy | 336,187 | 0xc6288e4353141e516b6e5d3e3292dc9f5ab9731a | 
| OneAddressPerGuard | 426,313 | 0xa362704a518f139b6c688a85c2c69792ea1b81f9 | 
| NFTMetadataRouterExtension | 535,214 | 0x54fb19f5fd357bca01c3dc39c228597921c484b3 | 
| PayoutAddressExtension | 632,639 | 0xd59cd254f9c384540e05245e9c6eaea26c5976cb | 
| FeeManager | 869,188 | 0x6d068b97a4353c5b23f64d1361208d32ae917979 | 
| ERC721FreeMintController | 1,906,671 | 0x6c7760b08ca1eed25fcff6f628eeda369ce11334 | 
| ERC721GasCoinPurchaseController | 2,013,611 | 0x39af6209325eb501361ccc33b36f589444959f9d | 
| ERC721StablecoinPurchaseController | 2,926,173 | 0x6c1ca4dd00c4bbd2a5d06b6b0bf3a80dcce0ba14 | 
| GeneralFreeMintController | 996,693 | 0x067EF1a8E8D79E55B94d9C8096FFb927108A53b3 | 
| PermissionGatedInitializer | 318,755 | 0x97a44D858c6B79E456828bfD86c1A0aD86b1677b | 
| InitializeAccountController | 961,478 | 0x6dBa22C55eA4549d1c92F181Cb33D7fe016E2f45 | 
| ERC721AccountRails | 4,117,521 | 0xD8dDE27Bd469148CD014c3C7CB1Eedf62C4949C0 | 
| AccountGroupImpl | 1,501,090 | 0x210ce6fD65C7765B9b7bfafd72F67E8F9a98Ce09 | 
| AccountGroupProxy | 59,670 | 0x12e58F259135b4B4ba87dff6086fB5D02C6A86ef | 
