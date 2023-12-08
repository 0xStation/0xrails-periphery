# Getting Started with GroupOS

This guide will walk through the steps for setting up a local development environment for building on-chain integrations
with GroupOS. We will use Foundry to install GroupOS and run a few simple tests.

At the end of this tutorial, we'll have a development environment set up that can be used to continue building the rest of the tutorials in the
"Guides" section.

## Pre-requisites

You will need the following software on your machine:

- [Git](https://git-scm.com/downloads)
- [Foundry](https://github.com/foundry-rs/foundry)
- [Node.js](https://nodejs.org/en/download)
- [Pnpm](https://pnpm.io)

In addition, familiarity with [Ethereum](https://ethereum.org/) and [Solidity](https://soliditylang.org/) is requisite.

## Quick start, from scratch

Foundry is a popular toolkit for developing on EVM networks, providing numerous powerful features that we use to build and maintain GroupOS Protocol.

Let's use this command to spin up a new Foundry project:

```shell
$ forge init new-project
$ cd new-project
```

Once the initialization completes, take a look around at what got set up:

```tree
├── foundry.toml
├── lib
├── script
├── src
└── test
```

The folder structure should be intuitive:

- `src` is where you’ll write Solidity contracts
- `test` is where you’ll write tests (also in Solidity)
- `script` is where you'll write scripts to perform actions like deploying contracts (you guessed it, in Solidity)
- `foundry.toml` is where you can configure your Foundry settings, which we will leave as is in this guide

## Installing GroupOS

Now that the repository has been initialized by Foundry, it's time to add GroupOS as a dependency. From the project root directory, run:

```shell
$ forge install git@github.com:0xStation/groupos.git
```

This command will add the GroupOS repository to the `lib` directory, which is where Foundry stores dependencies. Once completed, developing with GroupOS is a breeze. For example:

```solidity
pragma solidity 0.8.19;

import {Rails} from "groupos/lib/0xrails/src/Rails.sol";
import {Operations} from "groupos/lib/0xrails/src/lib/Operations.sol";

contract PaymentApp is Rails {

    constructor(address bestFriend) {
        _addPermission(Operations.TRANSFER, bestFriend);
    }
}
```

Great! The Foundry development environment has been successfully set up and you're ready to start building onchain integrations with GroupOS protocol.

## Next steps

Now that your environment is configured, explore the guides section to discover various GroupOS features available for integration. Remember to place project contracts (`.sol` files) in the `src` directory and their corresponding tests in `test`. Scripting is performed out of the `script` directory.

If you'd like to learn more about Foundry, check out the [Foundry Book](https://book.getfoundry.sh/), which contains numerous examples and tutorials. Knowing the more powerful features of Foundry will enable you to create more sophisticated projects using GroupOS.