### installs

- forge install

### deploy Local

- anvil
- forge script script/Deploy.s.sol:MyScript --fork-url http://localhost:8545 --private-key $PRIVATE_KEY0 --broadcast

### Deploy On-Chain

- geth account new
- geth account list

- forge script script/DeployMembership.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast

### Example of verifying on etherscan

forge verify-contract 0x0C461282106C3CD676091ebdAaA723Cd855fC1C2 ./src/membership/Membership.sol:Membership $ETHERSCAN_API_KEY --chain-id 5

### Current contract addresses

#### Goerli

##### FixedStablecoinPurchaseModule

0xDC955e3AEfc125348777D3A12c361678b58Aa434

##### Membership Implementation

0x8C78329C9545C50fB5566f4CE96AF6a521Af1A19

##### MembershipFactory

0xC3d69FA0F895dAF59E6CBEaf7a8b6A4783f639e3

##### Altman Membership

0x5702e91CFC8fde43dd540a2b999aDe98E798B0e6

##### Vanilla Renderer

0x5e2D6BB7681ED5B309CE61e0276160EB2b3c4888

##### Fake ERC20

0xD478219fDca296699A6511f28BA93a265E3E9a1b
