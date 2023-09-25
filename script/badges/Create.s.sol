// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "0xrails/access/permissions/Permissions.sol";
import {PermissionsStorage} from "0xrails/access/permissions/PermissionsStorage.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";

import {BadgesFactory} from "src/badges/factory/BadgesFactory.sol";
import {INFTMetadata} from "src/membership/extensions/NFTMetadataRouter/INFTMetadata.sol";

contract Create is Script {
    string public name = "Badges";
    string public symbol = "BADGES";

    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public paprika = 0x4b8c47aE2e5083EE6AA9aE2884E8051c2e4741b1;

    address public owner = sym;

    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address metadataURIExtension = 0xD130547Bfcb52f66d0233F0206A6C427d89F81ED; // goerli
        // EXTENSIONS
        bytes memory addTokenURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, INFTMetadata.ext_tokenURI.selector, address(metadataURIExtension)
        );
        bytes memory addContractURIExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, INFTMetadata.ext_contractURI.selector, address(metadataURIExtension)
        );

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitTurnkeyMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, turnkey);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin = abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, sym);

        // INIT
        bytes[] memory initCalls = new bytes[](6);
        initCalls[0] = addTokenURIExtension;
        initCalls[1] = addContractURIExtension;
        initCalls[2] = permitTurnkeyMintPermit;
        initCalls[3] = permitTurnkeyMint;
        initCalls[4] = permitFrogAdmin;
        initCalls[5] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        address badgesFactory = 0x3192BF082DD537944b09Da147C5AFbAf9d6dC11C; // goerli
        BadgesFactory(badgesFactory).create(owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
