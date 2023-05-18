// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import {Membership} from '../../src/membership/Membership.sol';
import "../../src/membership/MembershipFactory.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/modules/FixedStablecoinPurchaseModule.sol";
import { ERC20 } from "openzeppelin-contracts/token/ERC20/ERC20.sol";


// DEPLOY SCRIPT (goerli)
// forge script script/tokens/DeployAltman.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast

// VERIFY SCRIPT (goerli)
// forge verify-contract 0xC4B66df5F31f61e685D74A34Dacf0216CDCf19aD ./src/membership/MembershipFactory.sol:MembershipFactory $ETHERSCAN_API_KEY --chain-id 5
contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        address gUSDCImpl = 0xd35CCeEAD182dcee0F148EbaC9447DA2c4D449c4;
        address renderer = 0x0DAb51C6d469001D31FfdE15Db9E539d8bAC4125;
        MembershipFactory factory = MembershipFactory(0xC4B66df5F31f61e685D74A34Dacf0216CDCf19aD);
        address membershipInstance = factory.create(msg.sender, renderer, "Altman Membership", "ALTMAN");
        Membership membershipContract = Membership(membershipInstance);

        address fixedStablecoinPurchaseModuleImpl = 0x5Ea0ff4E291939CbAac4A89d0Dd58852e109B10D;
        FixedStablecoinPurchaseModule paymentModule = FixedStablecoinPurchaseModule(fixedStablecoinPurchaseModuleImpl);
        paymentModule.append(gUSDCImpl);
        address[] memory enabledTokens = new address[](1);
        enabledTokens[0] = gUSDCImpl;
        paymentModule.setup(membershipInstance, address(2), 0, paymentModule.enabledTokensValue(enabledTokens));

        Permissions.Operation[] memory operations = new Permissions.Operation[](1);
        operations[0] = Permissions.Operation.MINT;
        membershipContract.permit(fixedStablecoinPurchaseModuleImpl, membershipContract.permissionsValue(operations));
        vm.stopBroadcast();
    }
}
