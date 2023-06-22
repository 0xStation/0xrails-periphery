// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {FreeMintModule} from "src/membership/modules/FreeMintModule.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// forge script script/partners/DCamp.s.sol:DCamp --fork-url $POLYGON_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
contract DCamp is Script {
    string public name = "Polygon d.Camp";
    string public symbol = "DCAMP";
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;

    // address public owner = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d; // sym
    address public owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog

    // address public renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli
    address public renderer = 0x9AE8391F311292c8E241DB576C6d528932B1939f; // polygon
    // address public renderer = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // mainnet

    // address public onePerAddress = 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7; // goerli
    address public onePerAddress = 0xfD54A7a9E5df54872b07df99893CCD474C8f2b53; // polygon
    // address public onePerAddress = 0x86dF40AC8ac8ec0ebAB4f42a88A75bAef3873649; // mainnet

    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    // address public membershipImpl = 0x1b8C7a6b778eedE6DB61a8e01922b6F350810aDE; // goerli
    // address public membershipImpl = 0x0C461282106C3CD676091ebdAaA723Cd855fC1C2; // goerli
    // address public membershipImpl = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // polygon
    // address public membershipImpl = 0x629cB9eC3EF20624eb750E0670C1E2E81053Ab5A; // mainnet
    // address public membershipImpl;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address membershipImpl = address(new Membership());
        // address module = address(new FreeMintModule(owner, 0.001 ether));
        address module = address(new FreeMintModule(owner, 1 ether));

        // proxy
        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).init.selector, msg.sender, renderer, name, symbol);
        address proxy = address(new ERC1967Proxy(membershipImpl, initData));

        // config
        bytes memory permitModule = abi.encodeWithSelector(
            Permissions.permit.selector, module, operationPermissions(Permissions.Operation.MINT)
        );
        bytes memory guardMint =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.MINT, onePerAddress);
        bytes memory guardTransfer =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.TRANSFER, MAX_ADDRESS);
        bytes memory permitFrogUpgradeModuleData = abi.encodeWithSelector(
            Permissions.permit.selector, frog, operationPermissions(Permissions.Operation.UPGRADE)
        );
        bytes memory permitSymUpgradeModuleData = abi.encodeWithSelector(
            Permissions.permit.selector, sym, operationPermissions(Permissions.Operation.UPGRADE)
        );

        bytes[] memory setupCalls = new bytes[](5);
        setupCalls[0] = permitModule;
        setupCalls[1] = guardMint;
        setupCalls[2] = guardTransfer;
        setupCalls[3] = permitFrogUpgradeModuleData;
        setupCalls[4] = permitSymUpgradeModuleData;

        // // make non-atomic batch call, using permission as owner to do anything
        Batch(proxy).batch(true, setupCalls);
        // // transfer ownership to provided argument
        Permissions(proxy).transferOwnership(owner);
        vm.stopBroadcast();
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(Permissions.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}
