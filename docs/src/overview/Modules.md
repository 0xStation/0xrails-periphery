# Modules

Modules are smart contracts that bundle custom logic around core operations. Core operations are the actions you can take on a central primitive to change its state. For example, token primitives have the core operations of mint, burn, and transfer which mutate the fundamental storage of token balances and ownership.

While some core operations are exposed externally and therefore have a predefined behavior and control flow, e.g. token transfer, many core operations are kept internal when defined by ERC’s which leaves the use of them open to the developer. This is great for designing new standards, but leads to a fragmentation in the exposed external forms of these operations (how many different mint functions have you seen on an NFT contract that are all mostly the same).

Taking the idea of externalizing logic to its maximum, an NFT primitive actually does not need any opinions about when or how NFTs should be minted, burned, or transfered and can instead delegate that responsibility entirely to Modules. Modules connect fluidly to primitives, serving many simultaneously and each primitive can equivalently have many modules controlling it at once.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/fe64194d-02ca-4885-9587-def13891708d.png">

Modules are also great for creating multi-contract integrations that need to make related, protected operations atomically without trust. For example, we want to configure a loyalty system where we reward users by minting an NFT badge and fungible ERC20 in a known ratio that we can change over time. In a normal contract system, it is not obvious if this logic should live on the NFT contract, ERC20 contract, or force merging them together to one. However with Modules, it is intuitive to externalize this logic to a new loyalty system manager that configures NFT token ids to ERC20 values and has the permission on both contracts to control their minting operation behavior.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/2f1e787d-fc33-4b38-9963-a7b7d5fe0d4f.png">