# NFT Guide

## Creating an ERC721Rails NFT with the GroupOS TokenFactory

This tutorial will walk through writing a script to create an NFT collection using Foundry and the GroupOS TokenFactory. Since the NFT complies with the ERC721 standard, it will be compatible with all major marketplaces and wallets like OpenSea, MetaMask, and Coinbase Wallet.

The general flow of this tutorial can also be followed to create ERC20 and ERC1155 tokens using the very same TokenFactory.

Bear in mind that this tutorial is for educational purposes only.

## Start the project and install GroupOS

Start by setting up a Foundry project and installing GroupOS as a dependency by following the steps outlined in the [Getting Started section](./GettingStarted.md).

## Writing the NFT deployment script

Once your local environment is configured to your liking, let's get started writing a basic script to interact with the TokenFactory. 

First, delete all references to `Counter.*sol` in the src, script, and test as we won't need them.

Then, in the script directory, create a new file called `CreateERC721.s.sol` and start with the following boilerplate code:

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TokenFactory} from "groupos/factory/TokenFactory.sol";

contract CreateERC721 is Script {
    // todo
}
```

In the following code, we note a few things about the script:
  - it is unlicensed
  - it uses Solidity version 0.8.13 or above
  - it imports (and inherits) the Foundry helper `Script.sol`
  - it imports the GroupOS TokenFactory
  - it's called CreateERC721

Great! Now, a few things [about Foundry scripting](https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=scripting#solidity-scripting).

If you run into any questions or problems during this tutorial, check out the link above for more in-depth documentation of how Foundry scripts work.

### Foundry Scripts

Foundry provides a helper contract called `Script` which is unusual in a few ways. 

First and foremost, Solidity scripts that inherit `Script` are never deployed onchain. Instead, they are simulated to prepare transactions _offchain_.  

Another peculiarity is the `run()` function, which should be implemented by all Foundry scripts as it is searched for and run by default when executed. Let's add it to our contract:

```solidity
/*
... stuff from before
*/

contract CreateERC721 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        // todo

        vm.stopBroadcast();
    }
}
```

### Scripts require private keys

Great! As you can see there are some new Foundry quirks in the code to examine, the first being `vm.envUint("PRIVATE_KEY");`

This loads in the private key from a `.env` file located in the project root directory. This is not the only way to provide a private key to scripts, though it is the simplest for developers new to Solidity scripting and who may be familiar with web development environment variables. Alternatively, you could provide a private key from a terminal session's memory in the script's bash execution command using the `--private-key $PRIVATE_KEY` flag or the encrypted `--keystore $KEYSTORE` flag.

#### Note: you must be careful when exposing private keys in a .env file and loading them into memory. This is only recommended for use with non-privileged deployers or for local / test setups. For production setups please review the various wallet options that Foundry supports. Remember that storing private keys in plaintext is not secure and this tutorial is optimized for DevX and not for security!

### Broadcasts

As you learn to use Foundry, you'll start to encounter its cheatcodes which are invoked using `vm.someCheatCode()`.

This is no exception; we're using `vm.startBroadcast()`, a special cheatcode that records calls and contract creations made by our main script contract. 

Previously, we passed the private key in order to instruct it to use that key for signing the transactions. When executing the script, we will broadcast these transactions to the network instructing the TokenFactory to deploy our NFT contract.

### Configuration

Almost done! Let's add a few more lines to the run function:

```solidity
contract CreateERC721 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        // below addresses are for GroupOS v0.4.0
        TokenFactory tokenFactory = TokenFactory(0x2C333bd1316cE1aF9EBF017a595D6f8AB5f6BD1A);
        address ERC721RailsImplementation = address(0xB5764bd3AD21A58f723DB04Aeb97a428c7bdDE2a);

        // NFT configuration
        address owner = vm.addr(privateKey);
        string memory name = "Tutorial";
        string memory symbol = "TUT";

        // todo

        vm.stopBroadcast();
    }
}
```

You'll notice some new lines, declaring configuration variables for the TokenFactory and the NFT that will be deployed. When you populate the TokenFactory and ERC721RailsImplementation addresses, consult the [Deployment Addresses section](../overview/Deploys.md) for the most up to date deployments.

In this case, we're setting the owner of the new NFT collection to be the address that corresponds to the private key loaded from the .env file in the project root, which will be your address and also the one that will run the script. We've also given some very generic names to the collection: "Tutorial" and "TUT". Feel free to alter these to something more interesting.

### Calling the TokenFactory

Great! All that's left is to actually call the relevant function on the token factory onchain.

```solidity
contract CreateERC721 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        // below addresses are for GroupOS v0.4.0
        TokenFactory tokenFactory = TokenFactory(0x2C333bd1316cE1aF9EBF017a595D6f8AB5f6BD1A);
        address ERC721RailsImplementation = address(0xB5764bd3AD21A58f723DB04Aeb97a428c7bdDE2a);

        // NFT configuration
        address owner = vm.addr(privateKey);
        string memory name = "Tutorial";
        string memory symbol = "TUT";

        tokenfactory.createERC721(
            ERC721RailsImplementation,
            bytes32(0x0),
            owner,
            name,
            symbol,
            ''
        );

        vm.stopBroadcast();
    }
}
```

And there we have it, the script is complete. We're calling the `createERC721()` function on the TokenFactory and providing the configuration parameters we declared earlier.

Don't worry too much about the `bytes32(0x0)` and `''` parameters, as they are related to more complex topics called create2 and proxy contract initialization. Using empty/zero bytes as we did above should be more than enough to get started!

## Running the NFT deployment script

Now that we've written the script, it's time to execute it onchain! Start by adding some sensitive variables to your `.env` file in the project root.

```bash
echo "PRIVATE_KEY=<your_private_key>" >> .env
echo "RPC_URL=<your_rpc_endpoint>" >> .env
```

Be sure to pick the correct rpc endpoint url, because that'll determine the network to which the script transactions are broadcast, potentially costing you real money!

Once you've populated the `.env` file, you need to source it into your bash session:

`source .env`

Now we're ready to execute the script! Ready, set, go!

`forge script script/CreateERC721.s.sol --rpc-url $RPC_URL --broadcast --verify -vvvv`

Forge is going to run our script and broadcast the transactions for us - this can take a little while, since Forge will wait for the transaction receipts and also wait for Etherscan verification to go through.

If all has gone smoothly, you can check the transaction hash or your development address on the relevant block explorer and find the newly created NFT contract!

## Next steps

Once you've deployed an ERC721Rails NFT contract, some potential next steps to explore are:

  - Minting tokens to yourself and your friends
  - Burning tokens from your and your friends' addresses
  - Transferring tokens
  - Upgrading the token implementation

Happy hacking!