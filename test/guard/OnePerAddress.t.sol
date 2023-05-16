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
        setUp_membership();
    }

    function setUp_membership() public {
        membershipImpl = address(new Membership());
        membershipFactory = new MembershipFactory(membershipImpl, msg.sender);
    }

    function test_membershipMint(address owner, address account) public {
        vm.assume(owner != address(0));
        vm.assume(account != address(0));
        vm.assume(account != address(this));

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

    function test_membershipTransfer(address owner, address account1, address account2) public {
        vm.assume(owner != address(0));
        vm.assume(account1 != address(0) && account1 != address(this));
        vm.assume(account2 != address(0) && account2 != address(this));

        address proxy = membershipFactory.create(owner, rendererImpl, "Test", "TEST");
        vm.startPrank(owner);
        // set guard
        Permissions(proxy).guard(Permissions.Operation.TRANSFER, onePerAddress);
        // mint to two addresses, should pass
        uint256 token1 = Membership(proxy).mintTo(account1);
        Membership(proxy).mintTo(account2);
        assertEq(Membership(proxy).balanceOf(account1), 1);
        assertEq(Membership(proxy).balanceOf(account2), 1);
        vm.stopPrank();
        vm.startPrank(account1);
        // transfer 1->2, should fail
        vm.expectRevert("NOT_ALLOWED");
        Membership(proxy).transferFrom(account1, account2, token1);
        // balances still 1
        assertEq(Membership(proxy).balanceOf(account1), 1);
        assertEq(Membership(proxy).balanceOf(account2), 1);
        vm.stopPrank();
    }
}
