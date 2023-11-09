// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {GeneralFreeMintController} from "src/token/controller/GeneralFreeMintController.sol";
import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "lib/protocol-ops/script/lib/JsonManager.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {console2} from "forge-std/console2.sol";

// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $GOERLI_RPC_URL script/erc20/modules/FreeMintController.s.sol
// See deployed FreeMintController address in `Protocol-Ops::deploys.json`
contract DeployGeneralFreeMintModule is ScriptUtils {

    /*============
        CONFIG
    ============*/

    // following production contract will be deployed
    GeneralFreeMintController generalFreeMintController;
    // following contracts will also be deployed for local and staging environments:
    GeneralFreeMintController localGeneralFreeMintController;
    GeneralFreeMintController stagingGeneralFreeMintController;

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address _metadataRouter = $deploys.MetadataRouterProxy;

    /*===============
        BROADCAST 
    ===============*/

    function run() public {
        vm.startBroadcast();

        bytes32 salt = ScriptUtils.create2Salt;
        bytes32 saltLocal = bytes32(uint256(salt) + 1);
        bytes32 saltStaging = bytes32(uint256(salt) + 2);

        generalFreeMintController = new GeneralFreeMintController{salt: salt}(_metadataRouter);

        localGeneralFreeMintController = new GeneralFreeMintController{salt: saltLocal}(_metadataRouter);
        stagingGeneralFreeMintController = new GeneralFreeMintController{salt: saltStaging}(_metadataRouter);

        logAddress("GeneralFreeMintController @", Strings.toHexString(address(generalFreeMintController)));
        logAddress("GeneralFreeMintController @", Strings.toHexString(address(localGeneralFreeMintController)));
        logAddress("GeneralFreeMintController @", Strings.toHexString(address(stagingGeneralFreeMintController)));

        vm.stopBroadcast();
    }
}
