// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {FixedStablecoinPurchaseModule} from "../../src/modules/FixedStablecoinPurchaseModule.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// forge script script/partners/DoorsModule.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast
contract Deploy is Script {
    address public fakeToken = 0xD478219fDca296699A6511f28BA93a265E3E9a1b;
    address public paymentCollector = 0x7d29e5eba46eeF74B6fC643aEc6300D5FC74F7B5; // early doors safe
    address public owner = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D; // frog

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // proxy
        address proxy = 0x342Fa7307ef836c609C0D9FC4822CF92F8925a92;

        // purchase module
        FixedStablecoinPurchaseModule purchaseModule = FixedStablecoinPurchaseModule(0xEDa4e6bF1036bdC3816fD3adbaAf4142580AcB87);
        address[] memory enabledTokens = new address[](1);
        enabledTokens[0] = fakeToken;


        bytes memory setupModuleData = abi.encodeWithSelector(
            bytes4(keccak256("setup(address,uint256,bytes32)")), proxy, 30000, purchaseModule.enabledTokensValue(enabledTokens)
        );

        // config
        // permit module is failing somewhere
        // maybe it's reverting because the address of msg.sender is not the owner of the proxy
        bytes memory permitModule = abi.encodeWithSelector(
            Permissions.permitAndSetup.selector, address(purchaseModule), operationPermissions(Permissions.Operation.MINT), setupModuleData
        );


        bytes[] memory setupCalls = new bytes[](1);
        setupCalls[0] = permitModule;

        // make non-atomic batch call, using permission as owner to do anything
        Batch(proxy).batch(false, setupCalls);
        vm.stopBroadcast();
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function operationPermissions(Permissions.Operation operation) public pure returns (bytes32 value) {
        return bytes32(1 << uint8(operation));
    }
}