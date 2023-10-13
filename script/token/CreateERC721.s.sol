// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {PermissionsStorage} from "0xrails/access/permissions/PermissionsStorage.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {FeeManager} from "../../src/lib/module/FeeManager.sol";
import {FreeMintController} from "../../src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "../../src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "../../src/membership/modules/StablecoinPurchaseController.sol";
import {MetadataRouter} from "../../src/metadataRouter/MetadataRouter.sol";
import {TokenFactory} from "../../src/factory/TokenFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {INFTMetadata} from "src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol";

contract CreateERC721 is ScriptUtils {
    /*============
        CONFIG 
    ============*/

    /// @notice LINEA: v.1.10
    address coreImpl = 0x3F4f3680c80DBa28ae43FbE160420d4Ad8ca50E4; // ERC721Rails Linea

    address public owner = ScriptUtils.symmetry;
    string public name = "Symmetry Testing";
    string public symbol = "SYM";

    address public payoutAddress = ScriptUtils.turnkey;

    /// @notice GOERLI: v1.0.0
    // address public mintModule = 0x8226Ff7e6F1CD020dC23901f71265D7d47a636d4; // Free mint goerli
    // address public metadataURIExtension = 0xD130547Bfcb52f66d0233F0206A6C427d89F81ED; // goerli
    // address public payoutAddressExtension = 0x52Db1fa1B82B63842513Da4482Cd41b26c1Bc307; // goerli
    // address public membershipFactory = 0x08300cfDcF6dD1A6870FC2B1594804C0Be8076eC; // goerli

    /// @notice LINEA: v1.1.0
    address public mintModule = 0x966aD227192e665960A2d1b89095C16286Fc7792; // FreeMintController Linea
    address public NFTMetadataRouterExtension = 0x2D85bFA7E8C0e4E9D5185F69E8691c7886444E94;
    address public payoutAddressExtension = 0xc3c7Ef9d13E5027021a6fddeb63E05fd703a464F;
    address public tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af;

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
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, mintModule);
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

        TokenFactory(tokenFactory).createERC721(payable(coreImpl), owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
