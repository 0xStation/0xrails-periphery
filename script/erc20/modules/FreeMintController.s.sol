// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {FreeMintController} from "../../../src/erc20/modules/FreeMintController.sol";


// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/erc20/modules/FreeMintController.s.sol
contract DeployERC20FreeMintModule is ScriptUtils {

    function run() public {
        vm.startBroadcast();
        address _owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
        address _feeManager = 0x4B5f9B012842d449f84c93B1b9c85A730ea7cd7A;
        address _metadataRouter = 0xeB9359fB4154e4EF9B3Ba153aA86555F69Cd2E3E;

        new FreeMintController(_owner, _feeManager, _metadataRouter);
        vm.stopBroadcast();
    }
}
