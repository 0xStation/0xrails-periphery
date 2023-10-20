// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {FreeMintController} from "../../src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "../../src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "../../src/membership/modules/StablecoinPurchaseController.sol";
import {TokenFactory} from "../../src/factory/TokenFactory.sol";

contract CreateERC20 is ScriptUtils {
    /*============
        CONFIG
    ============*/

    /// @notice LINEA: v.1.10
    // address coreImpl = 0xe0dd2F320290d04Dce5432E6ec2312D66d6f84C1; // ERC20Rails Linea
    // address public mintModule = 0x966aD227192e665960A2d1b89095C16286Fc7792; // FreeMintController Linea
    // address public tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af; // tokenFactory Linea

    /// @notice GOERLI: v1.0.0
    address public coreImpl = 0xe0dd2F320290d04Dce5432E6ec2312D66d6f84C1; // ERC20Rails goerli
    address public mintModule = 0x8E019DfdA444743CA58065bd9b24Bd569b61fa75; // Free mint goerli
    address public tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af; // tokenFactory goerli

    address public owner = ScriptUtils.symmetry;
    string public name = "Symmetry Testing II";
    string public symbol = "SYMII";

    function run() public {
        vm.startBroadcast();

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitModuleMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, mintModule);
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

        TokenFactory(tokenFactory).createERC20(payable(coreImpl), owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
