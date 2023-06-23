// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {SetupPresets} from "src/lib/SetupPresets.sol";
import {FixedETHPurchaseModule} from "src/membership/modules/FixedETHPurchaseModule.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract MembershipFactoryGasTest is Test {
    MembershipFactory public membershipFactory;
    address public rendererImpl;
    address public membershipAddr;

    address public onePerAddress = address(7);
    address public turnkey = address(8);
    address public publicFreeMintModule = address(9);

    // we define constants outside of test functions to make sure gas tests are accurate
    address constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    bytes[] permitAndSetupCall;
    bytes[] ntOpaGrantCall;

    function setUp() public {
        rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
        address membershipFactoryTemplate = address(new MembershipFactory());
        membershipFactory = MembershipFactory(address(new ERC1967Proxy(membershipFactoryTemplate, "")));
        address fixedETHPurchaseModule = address(new FixedETHPurchaseModule(msg.sender, 0.01 ether));

        membershipFactory.initialize(address(new Membership()), address(this));
        SetupPresets.setupPresets(
            address(membershipFactory),
            onePerAddress,
            turnkey,
            publicFreeMintModule
        );

        // first contract deployed from this addr
        // should be 0xbb8AA747386Fc64EF3527a5a7E248002877e7269
        membershipAddr = address(uint160(uint(keccak256(abi.encodePacked(
            hex"d6_94", // from RLP encoding
            address(membershipFactory),
            hex"01"
        )))));

        permitAndSetupCall.push(abi.encodeWithSelector(
            Permissions.permitAndSetup.selector,
            fixedETHPurchaseModule, 
            Permissions.Operation.MINT,
            abi.encodeWithSelector(
                FixedETHPurchaseModule.setup.selector,
                membershipAddr, 
                1 ether // 1 * 10^18
            )
        ));

        ntOpaGrantCall = new bytes[](3);
        ntOpaGrantCall[0] = SetupPresets.nt;
        ntOpaGrantCall[1] = SetupPresets.opa(onePerAddress);
        ntOpaGrantCall[2] = SetupPresets.grant(turnkey);
    }

    function test_simple_create() public {
        membershipFactory.create(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS"
        );
    }

    function test_create_preset_nt_opa_grant() public {
        membershipFactory.createFromPresets(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            SetupPresets.ntOpaGrantHash
        );
    }

    function test_create_manual_nt_opa_grant() public {
        membershipFactory.createAndSetUp(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            ntOpaGrantCall
        );
    }

    function test_create_with_permit_and_setup_gas() public {
        membershipFactory.createAndSetUp(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            permitAndSetupCall
        );
    }
}
