// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {GeneralFreeMintController} from "src/token/controller/GeneralFreeMintController.sol";
import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "lib/protocol-ops/script/lib/JsonManager.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {console2} from "forge-std/console2.sol";

// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/erc20/modules/FreeMintController.s.sol
// See deployed FreeMintController address in `Protocol-Ops::deploys.json`
contract DeployGeneralFreeMintModule is ScriptUtils, Multicall {

    /*============
        CONFIG
    ============*/

    // following contract will be deployed
    GeneralFreeMintController generalFreeMintController;

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address _metadataRouter = $deploys.MetadataRouterProxy;

    /*===============
        BROADCAST 
    ===============*/

    function run() public {
        vm.startBroadcast();

        string memory saltString = "station";
        bytes32 salt = bytes32(bytes(saltString));

        generalFreeMintController = new GeneralFreeMintController{salt: salt}(_metadataRouter);

        vm.stopBroadcast();
    }
}
