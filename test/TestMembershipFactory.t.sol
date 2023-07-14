// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import "src/membership/MembershipFactory.sol";

contract MembershipFactoryTest is Test {
    address public minter = address(1);
    address public burner = address(2);
    address public receiver = address(3);
    address public paymentReciever = address(456);
    address public membershipFactory;
    address public rendererImpl;
    address public membershipImpl;

    function setUp() public {
        rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
        membershipImpl = address(new Membership());
        membershipFactory = address(new MembershipFactory());
        // Dummy beacon for testing
        MembershipFactory(membershipFactory).initialize(msg.sender, address(0));
    }

    function test_init() public {
        address membership =
            MembershipFactory(membershipFactory).createWithoutBeacon(membershipImpl, msg.sender, rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        assertEq(membershipContract.owner(), msg.sender);
        assertEq(membershipContract.renderer(), rendererImpl);
        assertEq(membershipContract.name(), "Friends of Station");
        assertEq(membershipContract.symbol(), "FRIENDS");
    }

    // testing that minting multiple memberships does not overwrite state in either one of them
    function test_multiple_memberships() public {
        address membership =
            MembershipFactory(membershipFactory).createWithoutBeacon(membershipImpl, msg.sender, rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        address membership2 =
            MembershipFactory(membershipFactory).createWithoutBeacon(membershipImpl, msg.sender, rendererImpl, "Enemies of Station", "ENEMIES");
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
                calls,
                false,
                membershipImpl
            );

        // call from non minter, expect fail
        vm.expectRevert("NOT_PERMITTED");
        Membership(membership).mintTo(receiver);

        // call from minter, expect success
        vm.prank(minter);
        uint tokenId = Membership(membership).mintTo(receiver);
        assertEq(Membership(membership).ownerOf(tokenId), receiver);

        // call from non burner, expect fail
        vm.expectRevert("NOT_PERMITTED");
        Membership(membership).burnFrom(tokenId);

        // call from burner, expect success
        vm.prank(burner);
        Membership(membership).burnFrom(tokenId);
        vm.expectRevert("ERC721: invalid token ID");
        Membership(membership).ownerOf(tokenId);
    }
}
