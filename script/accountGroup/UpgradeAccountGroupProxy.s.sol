// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "protocol-ops/script/lib/JsonManager.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IPermissions} from "0xrails/access/permissions/Permissions.sol";

import {AccountGroup} from "../../src/accountGroup/implementation/AccountGroup.sol";
import {PermissionGatedInitializer} from "../../src/accountGroup/initializer/PermissionGatedInitializer.sol";
import {InitializeAccountController} from "../../src/accountGroup/module/InitializeAccountController.sol";
import {ERC721AccountRails} from "0xrails/cores/ERC721Account/ERC721AccountRails.sol";

/// @dev Script to deploy entire AccountGroup infra to new chains
contract UpgradeAccountGroupProxyScript is ScriptUtils {
    /*=================
        ENVIRONMENT
    =================*/

    // The following contracts will be deployed:
    AccountGroup accountGroupImpl;

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;
    address erc721AccountRails = $deploys.ERC721AccountRails;

    // The following contracts will be upgraded:
    address accountGroup = $deploys.AccountGroupProxy; // production proxy

    bytes upgradeData; // configure if a function call is desired with the upgrade

    function run() public {
        /*===============
            BROADCAST
        ===============*/

        vm.startBroadcast();

        bytes32 salt = ScriptUtils.create2Salt;

        // begin deployments
        accountGroupImpl = new AccountGroup{salt: salt}();

        bytes memory upgradeCall =
            abi.encodeWithSelector(UUPSUpgradeable.upgradeToAndCall.selector, address(accountGroupImpl), upgradeData);

        Call3 memory accountGroupUpgradeCall = Call3({target: accountGroup, allowFailure: false, callData: upgradeCall});

        Call3[] memory calls = new Call3[](1);
        calls[0] = accountGroupUpgradeCall;

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        assert(AccountGroup(accountGroup).getDefaultAccountImplementation() == erc721AccountRails);

        vm.stopBroadcast();

        logAddress("NewAccountGroupImpl @", Strings.toHexString(address(accountGroupImpl)));
    }
}
