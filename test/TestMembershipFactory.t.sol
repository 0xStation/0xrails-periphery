// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import "src/membership/MembershipFactory.sol";

contract MembershipFactoryTest is Test {
    address public paymentReciever = address(456);
    address public membershipFactory;
    address public rendererImpl;
    address public membershipImpl;

    function setUp() public {
        rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
        membershipImpl = address(new Membership());
        membershipFactory = address(new MembershipFactory());
        MembershipFactory(membershipFactory).initialize(membershipImpl, msg.sender);
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
}
