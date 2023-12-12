// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {PermissionsStorage} from "0xrails/access/permissions/PermissionsStorage.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {FreeMintController} from "src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "src/membership/modules/StablecoinPurchaseController.sol";
import {MetadataRouter} from "src/metadataRouter/MetadataRouter.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {INFTMetadata} from "src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol";

contract CreateERC721 is ScriptUtils {
    /*============
        CONFIG 
    ============*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;
    address coreImpl = $deploys.ERC721Rails;
    address permitMintController = $deploys.PermitMintController;
    address NFTMetadataRouterExtension = $deploys.NFTMetadataRouterExtension;
    address payoutAddressExtension = $deploys.PayoutAddressExtension;
    address tokenFactory = $deploys.TokenFactoryProxy;

    string public name = "Symmetry Testing";
    string public symbol = "SYM";

    bytes32 salt = ScriptUtils.create2Salt;

    address public payoutAddress = ScriptUtils.turnkey;

    function run() public {
        vm.startBroadcast();

        // EXTENSIONS
        bytes memory addPayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, IPayoutAddress.payoutAddress.selector, address(payoutAddressExtension)
        );
        bytes memory addUpdatePayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.updatePayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addRemovePayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.removePayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addTokenURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, INFTMetadata.ext_tokenURI.selector, address(NFTMetadataRouterExtension)
        );
        bytes memory addContractURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            INFTMetadata.ext_contractURI.selector,
            address(NFTMetadataRouterExtension)
        );

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitModuleMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, permitMintController);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, symmetry);

        // INIT
        bytes[] memory initCalls = new bytes[](9);
        initCalls[0] = addPayoutAddressExtension;
        initCalls[1] = addUpdatePayoutAddressExtension;
        initCalls[2] = addRemovePayoutAddressExtension;
        initCalls[3] = addTokenURIExtension;
        initCalls[4] = addContractURIExtension;
        initCalls[5] = permitTurnkeyMintPermit;
        initCalls[6] = permitModuleMint;
        initCalls[7] = permitFrogAdmin;
        initCalls[8] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        TokenFactory(tokenFactory).createERC721(payable(coreImpl), salt, owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
