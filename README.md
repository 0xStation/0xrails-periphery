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
├── factory
│   ├── ITokenFactory.sol
│   └── TokenFactory.sol*
├── lib
│   ├── ContractMetadata.sol
│   ├── module
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
└── metadataRouter
    ├── IMetadataRouter.sol
    ├── MetadataRouter.sol*
    └── MetadataRouterStorage.sol
```

## Contributing

While GroupOS is in initial release, assistance on reviews for security and developer experience are most appreciated. In the meantime, please reach out directly via [Twitter DM](https://twitter.com/ilikesymmetry).

## License

Direct inquiries for using GroupOS in your own project via [Twitter DM](https://twitter.com/ilikesymmetry). Note that GroupOS is currently undergoing a security audit.

## Onchain Deployments
### Addresses are consistent across networks
#### The following addresses are v1.1.0, currently deployed to Optimism, Polygon, Linea and Goerli. For older versions deployed to other networks, consult `deploys.json`

| Contract | Gas | Address |
| --- | --- | --- |
| StationFounderSafe Multisig Proxy |  274,123 | 0xDd70fb41e936c5dc67Fc783BA5281E50f0A46fBC | 
| Station Safe Impl | 2,871,006 | 0x4aecEDCb5A1DD4615F57dF2672D5399b843F2469 | 
| Station Proxy Factory | 482,636 | 0x17841bb20729b25f23fdc6307dbccd883ad30f91 | 
| AdminGuard | 1,013,754 | 0xDB9A089A20D4b8cDef355ca474323b6C832D9776 | 
| CallPermitValidator | 770,771 | 0x234fe47240fbd6f0aa4573c16a0571969a735b13 | 
| BotAccountImpl | 4,179,853 | 0x645902b42714c1a8be5568f71c0b4e211c8e8e21 | 
| BotAccountProxy | 136,124 | 0xf5d53160846ed39dd819feecf548444364386ed3 | 
| ERC721Rails | 4,717,748 | 0x3f4f3680c80dba28ae43fbe160420d4ad8ca50e4 | 
| ERC20Rails | 3,879,187 | 0xe0dd2f320290d04dce5432e6ec2312d66d6f84c1 | 
| ERC1155Rails | 4,410,740 | 0x7a391860cf812e8151d9c578ca4cf36a015ddb79 |  
| TokenFactoryImpl | 2,087,959 | 0x079e4521ba03bc99321066261e8740d58f32bd45 | 
| TokenFactoryProxy | 259,529 | 0x66b28cc146a1a2cdf1073c2875d070733c7d01af | 
| MetadataRouterImpl | 1,915,882 | 0x1a1ab249c71e19e37be1ad7ac339146340158150 | 
| MetadataRouterProxy | 336,187 | 0x856ac2e3a5d065e8a505ceb0ca97906db8fa4b49 | 
| OneAddressPerGuard | 426,313 | 0x7A7fD9DE9738F815172989C65443A6Ce283dFb78 | 
| NFTMetadataRouterExtension | 535,214 | 0x2d85bfa7e8c0e4e9d5185f69e8691c7886444e94 | 
| PayoutAddressExtension | 632,639 | 0xc3c7ef9d13e5027021a6fddeb63e05fd703a464f | 
| FeeManager | 869,188 | 0x36b3acc10e7160e6003c621029c08a792e67be43 | 
| FreeMintController | 1,906,671 | 0x966ad227192e665960a2d1b89095c16286fc7792 | 
| GasCoinPurchaseController | 2,013,611 | 0xc4848d1e772c1385b86a2d3bfa56244a6122f700 | 
| StablecoinPurchaseController | 2,926,173 | 0xdd4f5f86d864ac806a98411e3fc87b74ca20dc2b | 

View deployments in [deploys.json](./deploys.json).
