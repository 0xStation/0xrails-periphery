// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {OnePerAddress} from "src/lib/guard/OnePerAddress.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {Badge} from "src/badge/Badge.sol";
import {BadgeFactory} from "src/badge/BadgeFactory.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Account as TBA} from "tokenbound/src/Account.sol";

// designed to make sure the payment module itself is working properly.
// different than TestPaymentModule which is designed to test if payment module can be added to a membership
// and work correctly with the membership.
contract OnePerAddressTest is Test {
    address public onePerAddress;
    address public rendererImpl;
    address public membershipImpl;
    MembershipFactory public membershipFactory;
    address public badgeImpl;
    BadgeFactory public badgeFactory;

    function setUp() public {
        onePerAddress = address(new OnePerAddress());
        rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
        // membership
        membershipImpl = address(new Membership());
        membershipFactory = new MembershipFactory();
        // NOTE: dummy beacon for testing
        membershipFactory.initialize(msg.sender, address(0));
        // badge
        badgeImpl = address(new Badge());
        badgeFactory = new BadgeFactory(badgeImpl, msg.sender);
    }

    // create Account that supports NFT receivers to avoid fuzz errors on existing contracts in testing ops
    function createAccount() public returns (address) {
        return address(new TBA(address(0)));
    }

    function test_membershipMint() public {
        address owner = createAccount();
        address account = createAccount();

        address proxy = membershipFactory.createWithoutBeacon(membershipImpl, owner, rendererImpl, "Test", "TEST");
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

    function test_membershipTransfer() public {
        address owner = createAccount();
        address account1 = createAccount();
        address account2 = createAccount();

        address proxy = membershipFactory.createWithoutBeacon(membershipImpl, owner, rendererImpl, "Test", "TEST");
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

    function test_badgeMint(uint256 tokenId) public {
        address owner = createAccount();
        address account = createAccount();

        address proxy = badgeFactory.create(owner, rendererImpl, "Test", "TEST");
        vm.startPrank(owner);
        // set guard
        Permissions(proxy).guard(Permissions.Operation.MINT, onePerAddress);
        // first mint, should pass
        Badge(proxy).mintTo(account, tokenId, 1);
        assertEq(Badge(proxy).balanceOf(account, tokenId), 1);
        // second mint, should fail
        vm.expectRevert("NOT_ALLOWED");
        Badge(proxy).mintTo(account, tokenId, 1);
        // balance still 1
        assertEq(Badge(proxy).balanceOf(account, tokenId), 1);
        vm.stopPrank();
    }

    function test_badgeTransfer(uint256 tokenId) public {
        address owner = createAccount();
        address account1 = createAccount();
        address account2 = createAccount();
        address account3 = createAccount();
        bytes memory data;

        address proxy = badgeFactory.create(owner, rendererImpl, "Test", "TEST");
        // set guard
        vm.startPrank(owner);
        Permissions(proxy).guard(Permissions.Operation.TRANSFER, onePerAddress);
        // mint to two addresses, should pass
        Badge(proxy).mintTo(account1, tokenId, 1);
        Badge(proxy).mintTo(account2, tokenId, 1);
        assertEq(Badge(proxy).balanceOf(account1, tokenId), 1);
        assertEq(Badge(proxy).balanceOf(account2, tokenId), 1);
        vm.stopPrank();
        // transfer 1->3, should work
        vm.startPrank(account1);
        Badge(proxy).safeTransferFrom(account1, account3, tokenId, 1, data);
        assertEq(Badge(proxy).balanceOf(account1, tokenId), 0);
        assertEq(Badge(proxy).balanceOf(account2, tokenId), 1);
        assertEq(Badge(proxy).balanceOf(account3, tokenId), 1);
        vm.stopPrank();
        // transfer 2->3, should fail
        vm.startPrank(account2);
        vm.expectRevert("NOT_ALLOWED");
        Badge(proxy).safeTransferFrom(account2, account3, tokenId, 1, data);
        assertEq(Badge(proxy).balanceOf(account1, tokenId), 0);
        assertEq(Badge(proxy).balanceOf(account2, tokenId), 1);
        assertEq(Badge(proxy).balanceOf(account3, tokenId), 1);
        vm.stopPrank();
    }
}
