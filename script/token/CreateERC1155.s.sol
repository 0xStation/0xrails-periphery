// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {FreeMintController} from "../../src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "../../src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "../../src/membership/modules/StablecoinPurchaseController.sol";
import {MetadataRouter} from "../../src/metadataRouter/MetadataRouter.sol";
import {TokenFactory} from "../../src/factory/TokenFactory.sol";
import {INFTMetadata} from "src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol";

contract CreateERC1155 is ScriptUtils {
    /*============
        CONFIG 
    ============*/

    /// @notice LINEA: v.1.10
    address coreImpl = 0x7a391860CF812E8151d9c578ca4CF36a015ddb79; // ERC1155Rails Linea
    
    address public owner = ScriptUtils.symmetry;
    string public name = "Symmetry Testing";
    string public symbol = "SYM";

    address public payoutAddress = ScriptUtils.turnkey;

    /// @notice GOERLI: v1.0.0
    // address public mintModule = 0x8226Ff7e6F1CD020dC23901f71265D7d47a636d4; // Free mint goerli
    // address public metadataURIExtension = 0xD130547Bfcb52f66d0233F0206A6C427d89F81ED; // goerli
    // address public payoutAddressExtension = 0x52Db1fa1B82B63842513Da4482Cd41b26c1Bc307; // goerli

    /// @notice LINEA: v1.1.0
    address public mintModule = 0x966aD227192e665960A2d1b89095C16286Fc7792; // FreeMintController Linea
    address public NFTMetadataRouterExtension = 0x2D85bFA7E8C0e4E9D5185F69E8691c7886444E94;
    address public payoutAddressExtension = 0xc3c7Ef9d13E5027021a6fddeb63E05fd703a464F;
    address public tokenFactory = 0x66B28Cc146A1a2cDF1073C2875D070733C7d01Af;

    function run() public {
        vm.startBroadcast();

        // EXTENSIONS
        bytes memory addTokenURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, INFTMetadata.ext_tokenURI.selector, address(NFTMetadataRouterExtension)
        );
        bytes memory addContractURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, INFTMetadata.ext_contractURI.selector, address(NFTMetadataRouterExtension)
        );

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitModuleMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, mintModule);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin = abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, symmetry);

        // INIT
        bytes[] memory initCalls = new bytes[](6);
        initCalls[0] = addTokenURIExtension;
        initCalls[1] = addContractURIExtension;
        initCalls[2] = permitTurnkeyMintPermit;
        initCalls[3] = permitModuleMint;
        initCalls[4] = permitFrogAdmin;
        initCalls[5] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);
        
        TokenFactory(tokenFactory).createERC1155(payable(coreImpl), owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
