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

## Deployment Addresses
### Addresses are consistent across networks
| Goerli | Sepolia |
| --- | --- |
| StationFounderSafe Multisig Proxy |  0x0f95a7b50eaeEFc08eb10Be44Dd48409b46372b2 |
| Station Safe Impl|  0x592B45e1A61E9057851013A8E945feDC78bC867E |
| Station Proxy Factory| 0xB5528CCE5BeB54f5180ac556a605863FA0310434 |
| CallPermitValidator | 0x82FaE7CB31Aa84Db8BCFD927f5C2c2A6383628f7 |
| BotAccountImpl | 0xfb72BeC7723f32d5F91d47c47Ed7b697AC8723b8 |
| BotAccountProxy | 0x8697226CC5150D3363D139872a4e462C6587fbC5 |
| ERC721Rails | 0xac06D8C535cb53F614d5C79809c778AB38343A63 |
| ERC20Rails | 0x9391eD3da2645CE9B7C8d718CDB4F101fA8d9D7b |
| ERC1155Rails | 0xb902C5610f6eE3206b6aC29579A411783AD5CB21 |
| BadgesFactoryImpl | 0x54d7E374e0EDA2Ba1AC9753882879A9151cbA059 |
| BadgesFactoryProxy | 0x77e9435A62fC8E7956bebe918F5e85BC328f5165 |
| PointsFactoryImpl | 0xeEBB0AeD46a87D22Aec722DEdF4Cc26eA63454c2 |
| PointsFactoryProxy | 0x9de62d5970356270E2790EAB4e3E6cF186868587 |
| MetadataRouterImpl | 0x25bb3D32fB94f9Bc43eF61dE4bc3829e79F47899 |
| MetadataRouterProxy | 0x52dcA284059C4b90ACB9C06CF479aA91DB2af3E8 |
| OneAddressPerGuard | 0x1577194B3F7F0D69B4869c378D8bC5Aa52e4567A |
| NFTMetadataRouterExtension | 0x3df5130b96e8Bc4f888F038177A09a36566642dC |
| PayoutAddressExtension | 0x564D62A78cDE39c6287E1499FF099Bf822Fc2Dd1 |
| FeeManager | 0x8f175F91Cd3E64dE60E294c0120c1768De51Cd4d |
| FreeMintModule | 0x9C4AE7b871b89Dd2b4F10B5FAB2D887419969584 |
| GasCoinPurchaseModule | 0xfb620377501995db139596274934674030E8620d |
| StablecoinPurchaseModule | 0xa4535fDdC3b10B23D1158feb41690CdF8cB8b1F7 |
| MembershipFactoryImpl | 0x3a6555AD03B35431813967778b8361ef5877fd13 |
| MembershipFactoryProxy | 0xdcee9376a3435c991758af3fd07e2830b3a41bcb |



## Directory Tree

```
* = deployed contract

lib/
  |- module/
      |- FeeManager*
      |- ModuleFee
      |- ModulePermit
      |- ModuleSetup
  |- ContractMetadata
  |- NonceBitMap
membership/
  |- extensions/
      |- NFTMetadataRouter/.
      |- PayoutAddress/.
  |- factory/
      |- MembershipFactory*
  |- guards/
     |- OnePerAddressGuard*
  |- modules/
      |- FreeMintModule*
      |- GasCoinPurchaseModule*
      |- StablecoinPurchaseModule*
metadataRouter/
  |- MetadataRouter*
```

## Contributing

While GroupOS is in initial release, assistance on reviews for security and developer experience are most appreciated. In the meantime, please reach out directly via [Twitter DM](https://twitter.com/ilikesymmetry).

## License

Direct inquiries for using GroupOS in your own project via [Twitter DM](https://twitter.com/ilikesymmetry). Note that GroupOS is currently un-audited with plans to audit in late 2023.

## Onchain Deployments

View deployments in [deploys.json](./deploys.json).
