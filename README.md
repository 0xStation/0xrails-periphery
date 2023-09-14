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

## Deployments

| EVM Network | ERC721Rails Address | MembershipFactory Address |
| --- | --- | --- |
| Goerli | [0x7ffb51b8b8381c094bd24da941d586cfd91b729c](https://goerli.etherscan.io/address/0x7ffb51b8b8381c094bd24da941d586cfd91b729c) | [0xc59EAFF8FFed977f02361dd99329A2217AaFC0E6](https://goerli.etherscan.io/address/0xc59EAFF8FFed977f02361dd99329A2217AaFC0E6) |
| Polygon | [0x7ffb51b8b8381c094bd24da941d586cfd91b729c](https://polygonscan.com/address/0x7ffb51b8b8381c094bd24da941d586cfd91b729c) | [0xc59EAFF8FFed977f02361dd99329A2217AaFC0E6](https://polygonscan.com/address/0xc59EAFF8FFed977f02361dd99329A2217AaFC0E6) |
| Mainnet | [0x7ffb51b8b8381c094bd24da941d586cfd91b729c](https://etherscan.io/address/0x7ffb51b8b8381c094bd24da941d586cfd91b729c) | [0xc59EAFF8FFed977f02361dd99329A2217AaFC0E6](https://etherscan.io/address/0xc59EAFF8FFed977f02361dd99329A2217AaFC0E6) |

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
