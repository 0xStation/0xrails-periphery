// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "lib/protocol-ops/script/lib/JsonManager.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";

contract CreateERC20 is ScriptUtils {
    /*============
        CONFIG
    ============*/

    // CONFIGURE BEFORE DEPLOYING
    address public owner = 0x016562aA41A8697720ce0943F003141f5dEAe006;
    string public name = "DonkeyPoints";
    string public symbol = "DP";

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address erc20CoreImpl = $deploys.ERC20Rails;
    address tokenFactory = $deploys.TokenFactoryProxy;
    address erc20FreeMintController = $deploys.GeneralFreeMintController;

    function run() public {
        vm.startBroadcast();

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitModuleMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, erc20FreeMintController);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, symmetry);

        // INIT
        bytes[] memory initCalls = new bytes[](4);
        initCalls[0] = permitTurnkeyMintPermit;
        initCalls[1] = permitModuleMint;
        initCalls[2] = permitFrogAdmin;
        initCalls[3] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        TokenFactory(tokenFactory).createERC20(payable(erc20CoreImpl), owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
