// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {FreeMintModule} from "src/membership/modules/FreeMintModule.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// forge script script/partners/Lobby3.s.sol:Lobby3 --fork-url $POLYGON_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
contract Lobby3 is Script {
    string public name = "Lobby3 UNA Membership";
    string public symbol = "LOBBY3";
    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;

    address public owner = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d; // sym
    // address public owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog

    address public renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli
    // address public renderer = 0x9AE8391F311292c8E241DB576C6d528932B1939f; // polygon
    // address public renderer = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // mainnet

    address public onePerAddress = 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7; // goerli
    // address public onePerAddress = 0xfD54A7a9E5df54872b07df99893CCD474C8f2b53; // polygon
    // address public onePerAddress = 0x86dF40AC8ac8ec0ebAB4f42a88A75bAef3873649; // mainnet

    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    address public membershipImpl = 0x7B9e83E1Fc68378a9FA9e4FFE2ff47318f1ECcfb; // goerli
    // address public membershipImpl = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // polygon
    // address public membershipImpl = 0x629cB9eC3EF20624eb750E0670C1E2E81053Ab5A; // mainnet
    // address public membershipImpl;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address module = 0xD429e7618fda0B681D0037938EbD4Bf24BfCe9eD;
        // address module = address(new FreeMintModule(owner, 1 ether));

        // proxy
        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).init.selector, msg.sender, renderer, name, symbol);
        address proxy = address(new ERC1967Proxy(membershipImpl, initData));

        // config

        // guards
        bytes memory guardMint =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.MINT, onePerAddress);
        bytes memory guardTransfer =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.TRANSFER, MAX_ADDRESS);
        // permits
        bytes memory permitModule = abi.encodeWithSelector(
            Permissions.permit.selector, module, operationPermissions(Permissions.Operation.MINT)
        );
        bytes memory permitGranting = abi.encodeWithSelector(
            Permissions.permit.selector, turnkey, operationPermissions(Permissions.Operation.GRANT)
        );
        bytes memory permitFrogUpgradeModuleData = abi.encodeWithSelector(
            Permissions.permit.selector, frog, operationPermissions(Permissions.Operation.UPGRADE)
        );
        bytes memory permitSymUpgradeModuleData = abi.encodeWithSelector(
            Permissions.permit.selector, sym, operationPermissions(Permissions.Operation.UPGRADE)
        );

        bytes[] memory setupCalls = new bytes[](6);
        setupCalls[0] = guardMint;
        setupCalls[1] = guardTransfer;
        setupCalls[2] = permitModule;
        setupCalls[3] = permitGranting;
        setupCalls[4] = permitFrogUpgradeModuleData;
        setupCalls[5] = permitSymUpgradeModuleData;

        // make batch call, using permission as owner to do anything
        Batch(proxy).batch(setupCalls);
        // transfer ownership to provided argument
        // Permissions(proxy).transferOwnership(owner);
        vm.stopBroadcast();
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(Permissions.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}
