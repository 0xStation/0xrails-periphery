// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {OnePerAddress} from "src/lib/guard/OnePerAddress.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";

// designed to make sure the payment module itself is working properly.
// different than TestPaymentModule which is designed to test if payment module can be added to a membership
// and work correctly with the membership.
contract OnePerAddressTest is Test {
    address public onePerAddress;
    address public rendererImpl;
    address public membershipImpl;
    MembershipFactory public membershipFactory;

    function setUp() public {
        onePerAddress = address(new OnePerAddress());
        rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
        setUpMembership();
    }

    function setUpMembership() public {
        membershipImpl = address(new Membership());
        membershipFactory = new MembershipFactory(membershipImpl, msg.sender);
    }

    function test_membership(address owner, address account) public {
        vm.assume(owner != address(0));
        vm.assume(account != address(0));

        address proxy = membershipFactory.create(owner, rendererImpl, "Test", "TEST");
        vm.startPrank(owner);
        // set guard
        Permissions(proxy).guard(Permissions.Operation.MINT, onePerAddress);
        // first mint, should pass
        Membership(proxy).mintTo(account);
        assertEq(Membership(proxy).balanceOf(account), 1);
        // second mint, should fail
        vm.expectRevert("NOT_ALLOWED");
        Membership(proxy).mintTo(account);
        // balance still 1
        assertEq(Membership(proxy).balanceOf(account), 1);
        vm.stopPrank();
    }
}
