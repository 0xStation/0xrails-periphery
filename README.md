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
├── badges
│   └── factory
│       ├── BadgesFactory.sol*
│       ├── BadgesFactoryStorage.sol
│       └── IBadgesFactory.sol
├── lib
│   ├── ContractMetadata.sol
│   ├── NonceBitMap.sol
│   └── module
│       ├── FeeManager.sol*
│       ├── ModuleFee.sol
│       ├── ModulePermit.sol
│       └── ModuleSetup.sol
├── membership
│   ├── extensions
│   │   ├── NFTMetadataRouter
│   │   │   ├── INFTMetadata.sol
│   │   │   ├── NFTMetadataRouter.sol
│   │   │   └── NFTMetadataRouterExtension.sol*
│   │   └── PayoutAddress
│   │       ├── IPayoutAddress.sol
│   │       ├── PayoutAddress.sol
│   │       ├── PayoutAddressExtension.sol*
│   │       └── PayoutAddressStorage.sol
│   ├── factory
│   │   ├── IMembershipFactory.sol
│   │   ├── MembershipFactory.sol*
│   │   └── MembershipFactoryStorage.sol
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
└── points
    └── factory
        ├── IPointsFactory.sol
        ├── PointsFactory.sol*
        └── PointsFactoryStorage.sol
```

## Contributing

While GroupOS is in initial release, assistance on reviews for security and developer experience are most appreciated. In the meantime, please reach out directly via [Twitter DM](https://twitter.com/ilikesymmetry).

## License

Direct inquiries for using GroupOS in your own project via [Twitter DM](https://twitter.com/ilikesymmetry). Note that GroupOS is currently un-audited with plans to audit in late 2023.

## Onchain Deployments
### Addresses are consistent across networks
#### * denotes testnet deployment, mainnet coming soon

| Contract | Gas | Address |
| --- | --- | --- |
| StationFounderSafe Multisig Proxy |  274,123 | 0x5d347E9b0e348a10327F4368a90286b3d1E7FB15 | 
| Station Safe Impl | 2,871,006 | 0x4aecEDCb5A1DD4615F57dF2672D5399b843F2469 | 
| Station Proxy Factory | 482,636 | 0x17841bb20729b25f23fdc6307dbccd883ad30f91 | 
| CallPermitValidator | 770,771 | 0x75d58aad25abacd5e9c30ef68159153fe1654846 | 
| BotAccountImpl | 4,179,853 | 0x37ec63afcab263c59c26b2725593ba9570d073b8 | 
| BotAccountProxy | 136,124 | 0x8fc712c40dcceda4e0efa93caf512d02200de30f | 
| ERC721Rails | 4,717,748 | 0xa03a52b4c8d0c8c64c540183447494c25f590e20 | 
| ERC20Rails | 3,879,187 | 0x7ffc6bb6f33111d88b0da80ac3dfe03bfca55c49 | 
| ERC1155Rails | 4,410,740 | 0x0070ac819452f7f5a0d02ff3c9c7a8bcfe7bba14 | 
| BadgesFactoryImpl | 1,516,793 | 0x54d7E374e0EDA2Ba1AC9753882879A9151cbA059* | 
| BadgesFactoryProxy | 326,036 | 0x77e9435A62fC8E7956bebe918F5e85BC328f5165* | 
| PointsFactoryImpl | 1,392,926 | 0xeEBB0AeD46a87D22Aec722DEdF4Cc26eA63454c2* | 
| PointsFactoryProxy | 212,264 | 0x9de62d5970356270E2790EAB4e3E6cF186868587* | 
| MembershipFactoryImpl | 1,390,807 | 0xec4de6a3bf2b598fef179dc4a6766fa0e73f143a | 
| MembershipFactoryProxy | 212,264 | 0xc5abb7832f6e5201f3f339429ec71a569ffe49f5 | 
| MetadataRouterImpl | 1,915,882 | 0x8166634a8972d5d06f50eb472906b6bc54214613 | 
| MetadataRouterProxy | 336,187 | 0xe63da895a4c35d011116fe13267cbfc7ef4b8314 | 
| OneAddressPerGuard | 426,313 | 0x1577194B3F7F0D69B4869c378D8bC5Aa52e4567A | 
| NFTMetadataRouterExtension | 535,214 | 0x4d3c0192650ed584d9fe89fc11ccbda437d274c8 | 
| PayoutAddressExtension | 632,639 | 0xc786b15615b62e1ff126969b2028ab10c86f5442 | 
| FeeManager | 869,188 | 0xd612dc76ff8cd0ec390208f267b26f9485534df3 | 
| FreeMintController | 1,906,671 | 0x19b3b28d76df5a1b90e6998edbf31e57094c31c1 | 
| GasCoinPurchaseController | 2,013,611 | 0x822bdae137f6a3d50801e5b744b2e99e35d8bee1 | 
| StablecoinPurchaseController | 2,926,173 | 0x75b899c58e1117f9e42276753e17949ef2aaa6dd | 

View deployments in [deploys.json](./deploys.json).
