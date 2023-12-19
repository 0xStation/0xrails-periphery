# Tokens

By default, GroupOS uses 0xRails token implementations, which are designed to maximally complement GroupOS features and enable new onchain paradigms. GroupOS also generally supports any token implementation that adheres to its ERC spec, as the protocol is designed with a permissionless crypto mindset.

The GroupOS token implementations for ERC20, ERC721, ERC1155 are each married with [0xRails::Rails](https://github.com/0xstation/0xrails/), which offers a comprehensive suite of customizable opt-in configurations including:
  - [granular, operation-based access control](./Access.md)
  - [guard contracts for each function](./Customization.md)
  - [function selector extensions similar to the Diamond Proxy pattern (ERC2535)](./Customization.md)
  - [arbitrary external call execution and batching](./Execution.md)

These mechanisms will be discussed at length later in the documentation as they reside deeper into GroupOS technicals than basic tokens, which is the scope of this page.

## ERC20Rails

The ERC20Rails token implementation uses the standard [OpenZeppelin::ERC20](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20) implementation with [0xRails::Rails](https://github.com/0xstation/0xrails/). In keeping with proxy smart contract best safety practices, [all storage is namespaced using ERC7201](https://station.mirror.xyz/Cmu86XLpHXj0VuHAdcMmnb-Ci7dwxU9k47UQQ3Mzp20). 

## ERC721Rails

The ERC721Rails token implementation uses [ERC721A token logic to enable gas-efficient batch minting](https://www.erc721a.org/) in combination with [ERC7201 namespaced storage](https://station.mirror.xyz/Cmu86XLpHXj0VuHAdcMmnb-Ci7dwxU9k47UQQ3Mzp20). This token implementation uses Rails to open the door to numerous interesting onchain possibilities such as streamlined support for [ERC6551 tokenbound accounts.](https://tokenbound.org/)

#### ERC721Rails + ERC6551 Integration Demo
Station Labs built out [a live demonstration of ERC721Rails tokens being used as tokenbound owners of ERC6551 accounts which can be used to play a web3 game, 0xPacman.](https://arcade.station.express/) We actively encourage developers to explore applications of Rails contracts with cutting-edge emerging blockchain standards like ERC6551.

#### Note for batch mints with ERC721Rails

As ERC721Rails uses the batch minting mechanism devised by ERC721A, a maximum batch size is implemented and declared as a constant. For more information, consult the [technical reference](../0xrails/src/cores/ERC721/ERC721.sol/abstract.ERC721.md#max_mint_batch_size)

## ERC1155Rails

Similarly to ERC20Rails, the ERC1155Rails token implementation uses the standard [OpenZeppelin::ERC1155](https://docs.openzeppelin.com/contracts/5.x/api/token/erc1155) implementation with [0xRails::Rails](https://github.com/0xstation/0xrails/), managing state using [ERC7201 namespaced storage](https://station.mirror.xyz/Cmu86XLpHXj0VuHAdcMmnb-Ci7dwxU9k47UQQ3Mzp20).

### Token metadata

The `contractURI()` function is inherited from Rails and thus present on all three Rails token implementations. This is worth mentioning as the inclusion of token metadata is out of the ordinary for fungible tokens. If you intend to build on ERC20Rails by inheriting it and do not wish to use the metadata functionality, simply leave it unimplemented.
