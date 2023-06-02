// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {FixedStablecoinPurchaseModule} from "src/membership/modules/FixedStablecoinPurchaseModule.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// forge script script/partners/EarlyDoors.s.sol:EarlyDoors --fork-url $MAINNET_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
contract EarlyDoors is Script {
    string public name = "Early Doors";
    string public symbol = "EARLYDOORS";

    uint256 public fee = 0.001 ether; // mainnet/goerli
    uint8 public decimals = 2;
    string public currency = "USD";
    uint128 public mintPrice = uint128(1000 * 10 ** decimals); // $1000

    // address public usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // mainnet
    address public usdcAddress = 0xD478219fDca296699A6511f28BA93a265E3E9a1b; // goerli, custom faucet token

    // address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    FixedStablecoinPurchaseModule public module =
        FixedStablecoinPurchaseModule(0x9c4969e1c585491Ac5382EeeB9BC9668f8a5788c); // v2

    address public paymentCollector = 0x7d29e5eba46eeF74B6fC643aEc6300D5FC74F7B5; // early doors safe
    // address public paymentCollector = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog

    address public owner = 0x7d29e5eba46eeF74B6fC643aEc6300D5FC74F7B5; // early doors safe
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;

    address public renderer = 0xf8A31352e237af670D5DC6e9b75a4401A37BaD0E; // goerli
    // address public renderer = 0x9AE8391F311292c8E241DB576C6d528932B1939f; // polygon
    // address public renderer = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // mainnet

    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    address public onePerAddress = 0x8626BFA8dc92262d98A96A9a5CE8CCFDB0c59cB7; // goerli
    // address public onePerAddress = 0xfD54A7a9E5df54872b07df99893CCD474C8f2b53; // polygon
    // address public onePerAddress = 0x86dF40AC8ac8ec0ebAB4f42a88A75bAef3873649; // mainnet

    address public membershipImpl = 0xfC6Eea2467f921C66063C8E2aDB193c44299e869; // goerli
    // address public membershipImpl = 0xA9879cbfa6a1Fe2964F37BcCD6fcF6ea61EfcDbf; // polygon
    // address public membershipImpl = 0x629cB9eC3EF20624eb750E0670C1E2E81053Ab5A; // mainnet

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // address membershipImpl = address(new Membership());

        FixedStablecoinPurchaseModule module = new FixedStablecoinPurchaseModule(sym, fee, decimals, currency);
        module.register(usdcAddress);

        bytes memory initData = abi.encodeWithSelector(Membership.init.selector, msg.sender, renderer, name, symbol);

        address proxy = address(new ERC1967Proxy(membershipImpl, initData));

        // config
        address[] memory enabledCoins = new address[](1);
        enabledCoins[0] = usdcAddress;
        bytes memory setupModuleData = abi.encodeWithSelector(
            bytes4(keccak256("setUp(uint128,bytes16)")), mintPrice, module.enabledCoinsValue(enabledCoins)
        );

        bytes memory permitModule = abi.encodeWithSelector(
            Permissions.permitAndSetup.selector,
            address(module),
            operationPermissions(Permissions.Operation.MINT),
            setupModuleData
        );

        bytes memory guardMint =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.MINT, onePerAddress);

        bytes memory guardTransfer =
            abi.encodeWithSelector(Permissions.guard.selector, Permissions.Operation.TRANSFER, MAX_ADDRESS);

        bytes memory addPaymentCollector =
            abi.encodeWithSelector(Membership.updatePaymentCollector.selector, paymentCollector);

        bytes memory permitFrogUpgradeModuleData = abi.encodeWithSelector(
            Permissions.permit.selector, frog, operationPermissions(Permissions.Operation.UPGRADE)
        );

        bytes memory permitSymUpgradeModuleData = abi.encodeWithSelector(
            Permissions.permit.selector, sym, operationPermissions(Permissions.Operation.UPGRADE)
        );

        bytes[] memory setupCalls = new bytes[](6);
        setupCalls[0] = permitModule;
        setupCalls[1] = guardMint;
        setupCalls[2] = guardTransfer;
        setupCalls[3] = addPaymentCollector;
        setupCalls[4] = permitFrogUpgradeModuleData;
        setupCalls[5] = permitSymUpgradeModuleData;

        Batch(proxy).batch(true, setupCalls);
        Permissions(proxy).transferOwnership(owner);

        vm.stopBroadcast();
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(Permissions.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}
