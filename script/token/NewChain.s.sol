// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {PermissionsStorage} from "0xrails/access/permissions/PermissionsStorage.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";

import {FeeManager} from "../../src/lib/module/FeeManager.sol";
import {FreeMintController} from "../../src/membership/modules/FreeMintController.sol";
import {GasCoinPurchaseController} from "../../src/membership/modules/GasCoinPurchaseController.sol";
import {StablecoinPurchaseController} from "../../src/membership/modules/StablecoinPurchaseController.sol";
import {MetadataRouter} from "../../src/metadataRouter/MetadataRouter.sol";
import {PayoutAddressExtension} from "../../src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {TokenFactory} from "../../src/factory/TokenFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {INFTMetadata} from "src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol";

contract NewChain is Script {
    string public name = "Symmetry Testing";
    string public symbol = "SYM";

    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public paprika = 0x4b8c47aE2e5083EE6AA9aE2884E8051c2e4741b1;

    address public owner = sym;

    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public payoutAddress = turnkey;

    // address public metadataURIExtension = 0xD130547Bfcb52f66d0233F0206A6C427d89F81ED; // goerli
    // address public payoutAddressExtension = 0x52Db1fa1B82B63842513Da4482Cd41b26c1Bc307; // goerli

    // address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    // address public membershipFactory = 0x08300cfDcF6dD1A6870FC2B1594804C0Be8076eC; // goerli

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // deploy();
        mint();

        vm.stopBroadcast();
    }

    function deploy() public {
        // PERMISSIONS
        bytes memory permitTurnkeyMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, turnkey);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin = abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, sym);

        // INIT
        bytes[] memory initCalls = new bytes[](3);
        initCalls[0] = permitTurnkeyMint;
        initCalls[1] = permitFrogAdmin;
        initCalls[2] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        address membershipImpl = address(new ERC721Rails());
        address membership = address(new ERC1967Proxy(membershipImpl, ""));

        IERC721Rails(membership).initialize(owner, name, symbol, initData);
    }

    function mint() public {
        address membership = 0x4D66E97536CF3433e201dA1Fc59170165Ff93Be4;
        IERC721Rails(membership).mintTo(sym, 1);
    }
}
