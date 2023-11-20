// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {PermitMintController} from "src/token/controller/PermitMintController.sol";
import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "lib/protocol-ops/script/lib/JsonManager.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {console2} from "forge-std/console2.sol";

// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/erc20/modules/FreeMintController.s.sol
// See deployed FreeMintController address in `Protocol-Ops::deploys.json`
contract DeployPermitMintController is ScriptUtils {
    /*============
        CONFIG
    ============*/

    // following contract will be deployed
    PermitMintController permitMintController;

    /*===============
        BROADCAST 
    ===============*/

    function run() public {
        vm.startBroadcast();

        bytes32 salt = ScriptUtils.create2Salt;
        string memory saltString = Strings.toHexString(uint256(salt), 32);

        permitMintController = new PermitMintController{salt: salt}();

        logAddress("PermitMintController @", Strings.toHexString(address(permitMintController)));

        vm.stopBroadcast();
    }
}
