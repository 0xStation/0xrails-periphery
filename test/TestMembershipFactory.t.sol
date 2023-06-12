// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import "src/membership/MembershipFactory.sol";
import {SetupPresets} from "src/lib/SetupPresets.sol";

contract MembershipFactoryTest is Test {
    address public minter = address(1);
    address public burner = address(2);
    address public receiver = address(3);
    address public paymentReciever = address(456);
    address public membershipFactory;
    address public rendererImpl;
    address public membershipImpl;

    address public onePerAddress = address(7);
    address public turnkey = address(8);
    address public publicFreeMintModule = address(9);

    address constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    function setUp() public {
        rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
        membershipImpl = address(new Membership());
        membershipFactory = address(new MembershipFactory());
        MembershipFactory(membershipFactory).initialize(membershipImpl, address(this));
    }

    function test_init() public {
        address membership =
            MembershipFactory(membershipFactory).create(msg.sender, rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        assertEq(membershipContract.owner(), msg.sender);
        assertEq(membershipContract.renderer(), rendererImpl);
        assertEq(membershipContract.name(), "Friends of Station");
        assertEq(membershipContract.symbol(), "FRIENDS");
    }

    // testing that minting multiple memberships does not overwrite state in either one of them
    function test_multiple_memberships() public {
        address membership =
            MembershipFactory(membershipFactory).create(msg.sender, rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        address membership2 =
            MembershipFactory(membershipFactory).create(msg.sender, rendererImpl, "Enemies of Station", "ENEMIES");
        Membership membershipContract2 = Membership(membership2);
        assertEq(membershipContract.owner(), msg.sender);
        assertEq(membershipContract.renderer(), rendererImpl);
        assertEq(membershipContract.name(), "Friends of Station");
        assertEq(membershipContract.symbol(), "FRIENDS");
        assertEq(membershipContract2.owner(), msg.sender);
        assertEq(membershipContract2.renderer(), rendererImpl);
        assertEq(membershipContract2.name(), "Enemies of Station");
        assertEq(membershipContract2.symbol(), "ENEMIES");
    }

    function checkGuards(address membership, address[5] memory expectedAddrs) internal {
        for (uint8 i = 0; i < 5; i++) {
            assertEq(
                Membership(membership).guardOf(Permissions.Operation(i)),
                expectedAddrs[i]
            );
        }
    }

    function checkPermits(address membership, address addr, uint8[5] memory permissions) internal {
        bytes32 addrPermissions = Membership(membership).permissionsOf(addr);

        for (uint8 i = 0; i < 5; i++) {
            assertEq(
                (addrPermissions >> uint8(i)) & bytes32(uint(1)),
                bytes32(uint(permissions[i]))
            );
        }
    }


    function test_create_and_setup() public {

        bytes[] memory calls = new bytes[](2);

        calls[0] = abi.encodeWithSelector(
            Permissions.permit.selector,
            minter,
            bytes32(1 << uint8(Permissions.Operation.MINT))
        );

        calls[1] = abi.encodeWithSelector(
            Permissions.permit.selector,
            burner,
            bytes32(1 << uint8(Permissions.Operation.BURN))
        );

        (address membership, ) =
            MembershipFactory(membershipFactory).createAndSetUp(
                msg.sender,
                rendererImpl,
                "Friends of Station",
                "FRIENDS",
                calls
            );

        // should have no guards
        checkGuards(membership, [address(0), address(0), address(0), address(0), address(0)]);

        // should have permits on minting and burning
        checkPermits(membership, minter, [0, 1, 0, 0, 0]);
        checkPermits(membership, burner, [0, 0, 1, 0, 0]);
    }

    function _setupPresets() public {
        SetupPresets.setupPresets(
            membershipFactory,
            onePerAddress,
            turnkey,
            publicFreeMintModule
        );
    }

    function test_create_from_preset_1() public {
        _setupPresets();
        (address membership,) = MembershipFactory(membershipFactory).createFromPresets(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            "turnkey"
        );

        // should have no guards
        checkGuards(membership, [address(0), address(0), address(0), address(0), address(0)]);

        // should have permit on mint
        checkPermits(membership, turnkey, [0, 1, 0, 0, 0]);
    }

    function test_create_from_preset_2() public {
        _setupPresets();
        (address membership,) = MembershipFactory(membershipFactory).createFromPresets(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            "nt+opa"
        );

        // should have guards on transfer and mint
        checkGuards(membership, [address(0), onePerAddress, address(0), MAX_ADDRESS, address(0)]);
    }

    function test_create_from_preset_3() public {
        _setupPresets();
        (address membership,) = MembershipFactory(membershipFactory).createFromPresets(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            "nt+opa+free"
        );

        // should have guards on transfer and mint
        checkGuards(membership, [address(0), onePerAddress, address(0), MAX_ADDRESS, address(0)]);

        // should have permit on mint
        checkPermits(membership, publicFreeMintModule, [0, 1, 0, 0, 0]);
    }

    function test_combination_create() public {
                _setupPresets();

        bytes[] memory calls = new bytes[](2);

        calls[0] = abi.encodeWithSelector(
            Permissions.guard.selector,
            Permissions.Operation.UPGRADE,
            MAX_ADDRESS
        );

        calls[1] = abi.encodeWithSelector(
            Permissions.permit.selector,
            burner,
            bytes32(1 << uint8(Permissions.Operation.BURN))
        );

        (address membership,) = MembershipFactory(membershipFactory).createFromPresetsAndSetUp(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            calls,
            "nt+opa+free"
        );


        // should have guards on transfer, mint and upgrade
        checkGuards(membership, [MAX_ADDRESS, onePerAddress, address(0), MAX_ADDRESS, address(0)]);

        // should have permit on mint and guard
        checkPermits(membership, publicFreeMintModule, [0, 1, 0, 0, 0]);
        checkPermits(membership, burner, [0, 0, 1, 0, 0]);
    }

    function test_combination_create_overwrite() public {
        _setupPresets();

        bytes[] memory calls = new bytes[](2);

        calls[0] = abi.encodeWithSelector(
            Permissions.guard.selector,
            Permissions.Operation.MINT,
            MAX_ADDRESS
        );

        calls[1] = abi.encodeWithSelector(
            Permissions.permit.selector,
            publicFreeMintModule,
            bytes32(0)
        );

        (address membership,) = MembershipFactory(membershipFactory).createFromPresetsAndSetUp(
            msg.sender,
            rendererImpl,
            "Friends of Station",
            "FRIENDS",
            calls,
            "nt+opa+free"
        );

        // expect calls to be redundant since presets are applied after calls in arg

        // should still have guards on transfer and mint
        checkGuards(membership, [address(0), onePerAddress, address(0), MAX_ADDRESS, address(0)]);

        // should still have permit on mint 
        checkPermits(membership, publicFreeMintModule, [0, 1, 0, 0, 0]);
    }

}
