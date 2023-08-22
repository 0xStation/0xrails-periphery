// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "mage/access/permissions/Permissions.sol";
import {PermissionsStorage} from "mage/access/permissions/PermissionsStorage.sol";
import {Operations} from "mage/lib/Operations.sol";
import {IExtensionsExternal as IExtensions} from "mage/extension/interface/IExtensions.sol";

import {FeeManager} from "../../src/lib/module/FeeManager.sol";
import {FreeMintModule} from "../../src/membership/modules/FreeMintModule.sol";
import {GasCoinPurchaseModule} from "../../src/membership/modules/GasCoinPurchaseModule.sol";
import {StablecoinPurchaseModule} from "../../src/membership/modules/StablecoinPurchaseModule.sol";
import {MetadataRouter} from "../../src/metadataRouter/MetadataRouter.sol";
import {NFTMetadataExtension} from "../../src/membership/extensions/NFTMetadata/NFTMetadataExtension.sol";
import {PayoutAddressExtension} from "../../src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {MembershipFactory} from "../../src/membership/factory/MembershipFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {INFTMetadata} from "src/membership/extensions/NFTMetadata/INFTMetadata.sol";

contract Create is Script {
    string public name = "Symmetry Testing";
    string public symbol = "SYM";

    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public paprika = 0x4b8c47aE2e5083EE6AA9aE2884E8051c2e4741b1;

    address public owner = sym;

    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public mintModule = 0x8226Ff7e6F1CD020dC23901f71265D7d47a636d4; // Free mint goerli
    address public payoutAddress = turnkey;

    address public metadataURIExtension = 0xD130547Bfcb52f66d0233F0206A6C427d89F81ED; // goerli
    address public payoutAddressExtension = 0x52Db1fa1B82B63842513Da4482Cd41b26c1Bc307; // goerli

    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    address public membershipFactory = 0x08300cfDcF6dD1A6870FC2B1594804C0Be8076eC; // goerli

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // EXTENSIONS
        bytes memory addPayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.payoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addSetPayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.setPayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addRemovePayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.removePayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addTokenURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            INFTMetadata.ext_tokenURI.selector,
            address(metadataURIExtension)
        );
        bytes memory addContractURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            INFTMetadata.ext_contractURI.selector,
            address(metadataURIExtension)
        );

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitModuleMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, mintModule);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, sym);

        // INIT
        bytes[] memory initCalls = new bytes[](9);
        initCalls[0] = addPayoutAddressExtension;
        initCalls[1] = addSetPayoutAddressExtension;
        initCalls[2] = addRemovePayoutAddressExtension;
        initCalls[3] = addTokenURIExtension;
        initCalls[4] = addContractURIExtension;
        initCalls[5] = permitTurnkeyMintPermit;
        initCalls[6] = permitModuleMint;
        initCalls[7] = permitFrogAdmin;
        initCalls[8] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        MembershipFactory(membershipFactory).createMembership(owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
