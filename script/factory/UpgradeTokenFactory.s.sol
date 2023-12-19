// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "protocol-ops/script/lib/JsonManager.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {ERC2771ContextInitializable} from "0xrails/lib/ERC2771/ERC2771ContextInitializable.sol";

/// @dev Script to deploy entire AccountGroup infra to new chains
contract UpgradeTokenFactoryScript is ScriptUtils {
    /*=================
        ENVIRONMENT
    =================*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;

    // The following contracts will be deployed:
    TokenFactory tokenFactoryImpl;

    // The following contracts will be upgraded:
    address tokenFactory = $deploys.TokenFactoryProxy; // production proxy

    // configure if a function call is desired with the upgrade
    bytes upgradeData = abi.encodeWithSelector(TokenFactory.setForwarder.selector, $deploys.ERC2771Forwarder);


    function run() public {
        /*===============
            BROADCAST
        ===============*/

        vm.startBroadcast();

        bytes32 salt = ScriptUtils.create2Salt;

        // begin deployments
        tokenFactoryImpl = new TokenFactory{salt: salt}();

        bytes memory upgradeCall =  abi.encodeWithSelector(
            UUPSUpgradeable.upgradeToAndCall.selector, address(tokenFactoryImpl), upgradeData
        );

        Call3 memory tokenFactoryUpgradeCall =
            Call3({target: tokenFactory, allowFailure: false, callData: upgradeCall});

        Call3[] memory calls = new Call3[](1);
        calls[0] = tokenFactoryUpgradeCall;

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        assert(Initializable(tokenFactory).initialized() == true);
        assert(ERC2771ContextInitializable(tokenFactory).trustedForwarder() == $deploys.ERC2771Forwarder);

        vm.stopBroadcast();

        logAddress("NewTokenFactoryImpl @", Strings.toHexString(address(tokenFactoryImpl)));
    }
}