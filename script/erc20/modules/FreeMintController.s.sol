// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {FreeMintController} from "../../../src/erc20/modules/FreeMintController.sol";


// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/erc20/modules/FreeMintController.s.sol
// deployed FreeMintController address: 0x8E019DfdA444743CA58065bd9b24Bd569b61fa75
contract DeployERC20FreeMintModule is ScriptUtils {

    function run() public {
        vm.startBroadcast();
        // deploy FreeMintController
        // address _owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
        // address _feeManager = 0x4B5f9B012842d449f84c93B1b9c85A730ea7cd7A;
        // address _metadataRouter = 0xeB9359fB4154e4EF9B3Ba153aA86555F69Cd2E3E;
        // new FreeMintController(_owner, _feeManager, _metadataRouter);

        // add collection to FreeMintController
        address sym2Collection = 0x8D007613435453041ec6d03E87a90117507065D0;
        FreeMintController fmc = FreeMintController(0x8E019DfdA444743CA58065bd9b24Bd569b61fa75);
        fmc.setUp(sym2Collection, true);

        vm.stopBroadcast();
    }
}
