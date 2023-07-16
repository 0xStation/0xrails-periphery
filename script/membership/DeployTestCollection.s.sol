// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {FreeMintModuleV2} from "src/membership/modules/FreeMintModuleV2.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// forge script script/partners/Lobby3.s.sol:Lobby3 --fork-url $POLYGON_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
contract DeployTestCollection is Script {
    string public name = "Evan Testing";
    string public symbol = "EVAN";

    address public user = 0x7202C5f49d23BdC051951E5798a1d374889849ed; // evan

    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public paprika = 0x4b8c47aE2e5083EE6AA9aE2884E8051c2e4741b1;

    address public owner = sym;

    address public renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli

    address public onePerAddress = 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7; // goerli

    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    address public membershipImpl = br; // goerli

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // proxy
        bytes memory initData =
            abi.encodeWithSelector(Membership(membershipImpl).init.selector, msg.sender, renderer, name, symbol);
        address proxy = address(new ERC1967Proxy(membershipImpl, initData));

        // config

        // no guards for testing

        // permits
        bytes memory permitTurnkeyGrant = abi.encodeWithSelector(
            Permissions.permit.selector, turnkey, operationPermissions(Permissions.Operation.GRANT)
        );
        bytes memory permitFrogUpgrade = abi.encodeWithSelector(
            Permissions.permit.selector, frog, operationPermissions(Permissions.Operation.UPGRADE)
        );
        bytes memory permitSymUpgrade = abi.encodeWithSelector(
            Permissions.permit.selector, sym, operationPermissions(Permissions.Operation.UPGRADE)
        );
        bytes memory permitUserUpgrade = abi.encodeWithSelector(
            Permissions.permit.selector, user, operationPermissions(Permissions.Operation.UPGRADE)
        );

        bytes[] memory setupCalls = new bytes[](4);
        setupCalls[0] = permitTurnkeyGrant;
        setupCalls[1] = permitFrogUpgrade;
        setupCalls[2] = permitSymUpgrade;
        setupCalls[3] = permitUserUpgrade;

        // make atomic batch call, using permission as owner to do anything
        Batch(proxy).batch(true, setupCalls);
        // transfer ownership to provided argument
        // Permissions(proxy).transferOwnership(owner);
        vm.stopBroadcast();
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(Permissions.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}