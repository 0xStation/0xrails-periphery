// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../src/lib/renderer/Renderer.sol";
import "../../src/membership/MembershipFactory.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/lib/SetupPresets.sol";

// DEPLOY SCRIPT (goerli)
// forge script script/membership/DeployFactory.s.sol:Deploy --fork-url $GOERLI_RPC_URL --keystores $ETH_KEYSTORE --password $KEYSTORE_PASSWORD --sender $ETH_FROM --broadcast

// VERIFY SCRIPT (goerli)
// forge verify-contract 0xC4B66df5F31f61e685D74A34Dacf0216CDCf19aD ./src/membership/MembershipFactory.sol:MembershipFactory $ETHERSCAN_API_KEY --chain-id 5
contract Deploy is Script {

    address onePerAddress = address(0);
    address turnkey = address(0);
    address publicFreeMintModule = address(0);

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // address membershipImpl = address(new Membership());
        address membershipImpl = 0xadBc7EC633B78dc4407215D56Eb0861dD7c51431;
        
        MembershipFactory membershipFactoryImpl = new MembershipFactory();
        ERC1967Proxy membershipFactoryProxy = new ERC1967Proxy(address(membershipFactoryImpl), "");

        // safety, for prod
        if (onePerAddress != address(0) && turnkey != address(0) && publicFreeMintModule != address(0)) {
            MembershipFactory(address(membershipFactoryProxy)).initialize(membershipImpl, address(this));
            SetupPresets.setupPresets(
                membershipFactoryProxy,
                onePerAddress,
                turnKey,
                publicFreeMintModule
            );
            MembershipFactory(address(membershipFactoryProxy)).transferOwnership(msg.sender);
        } else {
            MembershipFactory(address(membershipFactoryProxy)).initialize(membershipImpl, msg.sender);
        }
        
        vm.stopBroadcast();
    }
}
