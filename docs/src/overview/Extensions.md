# Extensions

Extensions are modular contracts that extend the state and operations of a contract. Due to size limitations on smart contracts and inevitable divergence in functionality for a given core primitive, modular Extensions enable infinite expansion of a contract’s state, logic, and customization. 

For example, add a streak-staking program to your token by creating new state for tracking which tokens are locked and functions to view, stake, and unstake tokens.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/511c184b-f4a4-4722-ae00-6712b5c32fba.png">

Extensions are a simplified and optimized version of Diamond Proxies (EIP-2535), focusing on the minimum viable implementation to enumerate a core primitive’s enabled Extensions directly from the contract without reliance on an indexer. These design decisions were made to improve code readability, simplify the developer experience, and optimize gas consumption.

Like Modules, Extensions connect fluidly to primitives, serving many simultaneously and each primitive can equivalently have many Extensions enabled it at once.

<img width="700" alt="image" src="https://station-images.nyc3.digitaloceanspaces.com/b0397ce2-618a-4fe7-a614-9bbf8ee32d90.png">
