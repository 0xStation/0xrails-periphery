# TokenFactory

GroupOS provides a public token factory contract which can be accessed by anyone wishing to deploy a new token contract. Simply provide initialization data for the token including name, symbol, and contract owner to [one of the create functions](..//factory/TokenFactory.sol/contract.TokenFactory.md#createerc721).

#### Contract Address

The onchain contract address for the TokenFactory can be found [in the Deployment Address section](../overview/Deploys.md)

### Token implementation whitelist

Wherever possible, GroupOS emphasizes a permissionless mindset, opting for compatibility with all tokens adhering to an ERC standard. The `TokenFactory` contract is the sole exception to this general rule. 

By design, the factory restricts token contract creation to [whitelisted 0xRails token implementation addresses](..//factory/TokenFactory.sol/contract.TokenFactory.md#getapprovedimplementations). This restriction has been put in place in order to protect GroupOS from reputational damage that could result from malicious token contracts created using our factory.

Should a factory for custom token implementations be desired, developers are encouraged to fork our TokenFactory and remove the whitelist restriction.