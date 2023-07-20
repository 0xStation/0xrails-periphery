// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {MembershipBeacon} from "src/lib/beacon/MembershipBeacon.sol";
import {Permissions} from "src/lib/Permissions.sol";

contract MembershipFactoryTest is Test {
    address public minter = address(1);
    address public burner = address(2);
    address public receiver = address(3);
    address public paymentReciever = address(456);

    MembershipFactory public membershipFactory;
    MembershipBeacon public membershipBeacon;
    Renderer public rendererImpl;
    Membership public membershipImpl;

    function setUp() public {
        rendererImpl = new Renderer(msg.sender, "https://tokens.station.express");
        membershipImpl = new Membership();
        membershipBeacon = new MembershipBeacon();
        membershipFactory = new MembershipFactory();

        membershipBeacon.initialize(msg.sender, address(membershipImpl));
        membershipFactory.initialize(msg.sender, address(membershipBeacon));
    }

    function test_init() public {
        address membership =
            membershipFactory.createWithBeacon(msg.sender, address(rendererImpl), "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);

        assertEq(membershipContract.owner(), msg.sender);
        assertEq(membershipContract.renderer(), address(rendererImpl));
        assertEq(membershipContract.name(), "Friends of Station");
        assertEq(membershipContract.symbol(), "FRIENDS");
    }

    // testing that minting multiple memberships does not overwrite state in either one of them
    function test_multiple_memberships() public {
        address membership =
            membershipFactory.createWithBeacon(msg.sender, address(rendererImpl), "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        address membership2 =
            membershipFactory.createWithBeacon(msg.sender, address(rendererImpl), "Enemies of Station", "ENEMIES");
        Membership membershipContract2 = Membership(membership2);

        assertEq(membershipContract.owner(), msg.sender);
        assertEq(membershipContract.renderer(), address(rendererImpl));
        assertEq(membershipContract.name(), "Friends of Station");
        assertEq(membershipContract.symbol(), "FRIENDS");
        assertEq(membershipContract2.owner(), msg.sender);
        assertEq(membershipContract2.renderer(), address(rendererImpl));
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
                address(rendererImpl),
                "Friends of Station",
                "FRIENDS",
                calls
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
