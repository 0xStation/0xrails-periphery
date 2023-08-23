// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {Permissions} from "mage/access/permissions/Permissions.sol";
import {PermissionsStorage} from "mage/access/permissions/PermissionsStorage.sol";
import {Operations} from "mage/lib/Operations.sol";
import {IExtensions} from "mage/extension/interface/IExtensions.sol";

import {PointsFactory} from "../../src/points/factory/PointsFactory.sol";

contract Create is Script {
    string public name = "Jungle Juice";
    string public symbol = "JJ";

    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public paprika = 0x4b8c47aE2e5083EE6AA9aE2884E8051c2e4741b1;

    address public owner = sym;

    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;

    address public membershipFactory = 0xC727b7c9123fEc809E896C530AAfeA7Eda8fc684; // goerli

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // PERMISSIONS
        bytes memory permitTurnkeyMintPermit =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT_PERMIT, turnkey);
        bytes memory permitTurnkeyMint =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.MINT, turnkey);
        bytes memory permitFrogAdmin =
            abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, frog);
        bytes memory permitSymAdmin = abi.encodeWithSelector(Permissions.addPermission.selector, Operations.ADMIN, sym);

        // INIT
        bytes[] memory initCalls = new bytes[](4);
        initCalls[0] = permitTurnkeyMintPermit;
        initCalls[1] = permitTurnkeyMint;
        initCalls[2] = permitFrogAdmin;
        initCalls[3] = permitSymAdmin;

        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

        PointsFactory(membershipFactory).create(owner, name, symbol, initData);

        vm.stopBroadcast();
    }
}
