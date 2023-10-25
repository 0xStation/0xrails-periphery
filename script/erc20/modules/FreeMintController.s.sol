// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {FreeMintController} from "../../../src/erc20/modules/FreeMintController.sol";
import {console2} from "forge-std/console2.sol";

// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/erc20/modules/FreeMintController.s.sol
// See deployed FreeMintController address in `Protocol-Ops::deploys.json`
contract DeployERC20FreeMintModule is ScriptUtils {

    /*============
        CONFIG
    ============*/

    // following contract will be deployed
    FreeMintController erc20FreeMintModule;

    /*===============
        BROADCAST 
    ===============*/

    function run() public {
        vm.startBroadcast();

        string memory saltString = "station";
        bytes32 salt = bytes32(bytes(saltString));

        new FreeMintController{salt: salt}();

        vm.stopBroadcast();
    }
}
