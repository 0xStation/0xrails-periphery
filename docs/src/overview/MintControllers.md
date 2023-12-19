# Mint Controllers

GroupOS offers modularized mints via delegating minting capabilities to specialized smart contracts residing onchain called controllers. Enabling controllers for a token collection is entirely opt-in, decided by the collection itself. Controllers support all three common token standards: ERC20, ERC721, and ERC1155.

Controllers essentially take the logic that wraps a core operation, like minting a token, out of the primitive’s contract and into another contract that has permission to call the core primitive. For example, GroupOS offers a controller called GasCoinPurchaseController that factiliates the purchase of an ERC-721 NFT with the network’s native gas coin, e.g. ETH. This controller is responsible for guaranteeing that the NFT collection creator gets paid, the minter gets an NFT, and Station receives a reward for facilitating the transaction.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/72c5411d-acd2-4253-aced-7ae0ff29d620.png">

Using mint controllers, GroupOS supports mints that include but are not limited to:
  - Completely free, gasless mints (using permit signatures with gas sponsorship)
  - Traditional free mints
  - Flat fee mints similar to Zora
  - Priced mints using a native blockchain currency ($ETH, $MATIC, $xDAI etc)
  - Priced mints using ERC20 tokens (stablecoins, governance tokens etc) 

#### Contract Addresses

Onchain contract addresses for existing mint controllers can be found [in the Deployment Address section](../overview/Deploys.md)

#### Enabling a Controller

On a high level, the process of enabling a controller is quite simple: contracts need only grant the desired controller permission to mint. This is achieved using the 0xRails Permissions system which is out of scope for this document but will be discussed at length [later in the documentation](../overview/Access.md).

To facilitate choosing the appropriate controller, information about each is listed below.

### Free + Gasless Mints using the PermitMintController

The PermitMintController is designed for completely free, gasless mints by using GroupOS's signature-based authentication, called "Permits". A provided ECDSA signature is recovered to a signer address and then verification is performed by routing the signer address through the 0xRails Permissions system.

  - Supports minting for all three 0xRails token standard implementations (ERC20, ERC721, ERC1155).
  - Calls the token collection to check that the recovered signer address has been granted permission via the `MINT_PERMIT` operation.
  - Does not make use of the FeeManager, as this controller is _entirely fee-free_.

### Free Mints using the ERC721FreeMintController

The ERC721FreeMintController is designed for collections who desire a traditional free mint, where NFTs are free of charge and users (or generic callers) pay gas for their own mint transaction.

  - Supports minting for 0xRails NFTs only (ERC721)
  - Supports minting via meta-transactions, ie "Permits". Signer addresses must possess permission for the `MINT_PERMIT` operation
  - Supports custom fees (separate from mint price) on a per-collection basis through the GroupOS FeeManager

### Priced Mints using the ERC721GasCoinPurchaseController (paid with Native Chain Currency)

The ERC721GasCoinPurchaseController is designed for collections who desire a traditional paid mint, where minters pay to mint NFTs using the native currency of the network (such as $ETH or $MATIC).

  - Supports minting for 0xRails NFTs only (ERC721)
  - Supports minting via meta-transactions, ie "Permits". Signer addresses must possess permission for the `MINT_PERMIT` operation
  - Supports custom fees on a per-collection basis through the GroupOS FeeManager

### Priced Mints using the ERC721StablecoinPurchaseController (paid with ERC20 tokens)

The ERC721 StablecoinPurchaseController is designed for collections who want to support paid mints using ERC20 tokens such as stablecoins or governance tokens. 

  - Note that this controller is expected to be deprecated in the next GroupOS release.
  - Supports minting for 0xRails NFTs only (ERC721)
  - Supports minting via meta-transactions, ie "Permits". Signer addresses must possess permission for the `MINT_PERMIT` operation
  - Supports custom fees on a per-collection basis through the GroupOS FeeManager
