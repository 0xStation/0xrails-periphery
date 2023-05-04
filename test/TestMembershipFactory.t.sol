// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/lib/renderer/Renderer.sol";
import "../src/membership/Membership.sol";
import "../src/membership/MembershipFactory.sol";

contract Blank is Test {
  address public membershipFactory;
  address public rendererImpl;
  address public membershipImpl;

  function setUp() public {
    rendererImpl = address(new Renderer(msg.sender, "https://tokens.station.express"));
    membershipImpl = address(new Membership());
    membershipFactory = address(new MembershipFactory(membershipImpl, msg.sender));
  }

  function test_init() public {
    address membership = MembershipFactory(membershipFactory).create(msg.sender, rendererImpl, "Friends of Station", "FRIENDS");
    Membership membershipContract = Membership(membership);
    assertEq(membershipContract.owner(), msg.sender);
    assertEq(membershipContract.renderer(), rendererImpl);
    assertEq(membershipContract.name(), "Friends of Station");
    assertEq(membershipContract.symbol(), "FRIENDS");
  }

}
