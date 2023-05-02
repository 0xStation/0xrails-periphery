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

forge verify-contract 0x139e89fCAb8bBB005358b1362175069F20cCa138 ./src/membership/Membership.sol:Membership $ETHERSCAN_API_KEY --chain-id 5
