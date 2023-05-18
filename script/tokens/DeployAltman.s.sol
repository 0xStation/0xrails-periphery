// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import {Membership} from '../../src/membership/Membership.sol';
import "../../src/membership/MembershipFactory.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/modules/FixedStablecoinPurchaseModule.sol";
import { FakeERC20 } from "../../test/utils/FakeERC20.sol";


// DEPLOY SCRIPT (goerli)
// forge script script/tokens/DeployAltman.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast

// VERIFY SCRIPT (goerli)
// forge verify-contract 0xC4B66df5F31f61e685D74A34Dacf0216CDCf19aD ./src/membership/MembershipFactory.sol:MembershipFactory $ETHERSCAN_API_KEY --chain-id 5
contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // FakeERC20 fakeToken = new FakeERC20(18);
        FakeERC20 fakeToken = FakeERC20(0xD478219fDca296699A6511f28BA93a265E3E9a1b);
        // Renderer renderer = new Renderer(msg.sender, "https://members.station.express/api/v1/nftMetadata");
        Renderer renderer = Renderer(0x5e2D6BB7681ED5B309CE61e0276160EB2b3c4888);
        // Membership membershipImpl = new Membership();
         Membership membershipImpl = Membership(0x8C78329C9545C50fB5566f4CE96AF6a521Af1A19);
        // MembershipFactory factory = new MembershipFactory(address(membershipImpl), msg.sender);
        MembershipFactory factory = MembershipFactory(0xC3d69FA0F895dAF59E6CBEaf7a8b6A4783f639e3);
        // FixedStablecoinPurchaseModule purchaseModule = new FixedStablecoinPurchaseModule(msg.sender, 0.001 ether, "USD", 2);
        FixedStablecoinPurchaseModule purchaseModule = FixedStablecoinPurchaseModule(0xDC955e3AEfc125348777D3A12c361678b58Aa434);

        purchaseModule.append(address(fakeToken));
        address[] memory enabledTokens = new address[](1);
        enabledTokens[0] = address(fakeToken);

        bytes memory setupModuleData =
            abi.encodeWithSelector(bytes4(keccak256("setup(address,uint256,bytes32)")), msg.sender, 1, purchaseModule.enabledTokensValue(enabledTokens));

        bytes memory permitMintModuleData =
            abi.encodeWithSelector(Permissions.permitAndSetup.selector, purchaseModule, permissionsValue(Permissions.Operation.MINT, address(membershipImpl)), setupModuleData);

        bytes memory permitFrogUpgradeModuleData =
            abi.encodeWithSelector(Permissions.permit.selector, 0x65A3870F48B5237f27f674Ec42eA1E017E111D63, permissionsValue(Permissions.Operation.UPGRADE, address(membershipImpl)));

        bytes memory permitSymUpgradeModuleData =
            abi.encodeWithSelector(Permissions.permit.selector, 0x016562aA41A8697720ce0943F003141f5dEAe006, permissionsValue(Permissions.Operation.UPGRADE, address(membershipImpl)));

        bytes[] memory setupCalls = new bytes[](3);
        setupCalls[0] = permitMintModuleData;
        setupCalls[1] = permitFrogUpgradeModuleData;
        setupCalls[2] = permitSymUpgradeModuleData;
        factory.createAndSetup(msg.sender, address(renderer), "Altman Membership", "ALTMAN", setupCalls);
        vm.stopBroadcast();
    }

  function permissionsValue (Permissions.Operation operation, address membershipImpl) public pure returns (bytes32) {
    Permissions.Operation[] memory operations = new Permissions.Operation[](1);
    operations[0] = operation;
    return Permissions(membershipImpl).permissionsValue(operations);
  }
}
