// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/lib/renderer/Renderer.sol";
import "../src/membership/Membership.sol";
import "../src/membership/MembershipFactory.sol";
import "../src/modules/FixedETHPurchaseModule.sol";

contract PaymentModuleTest is Test {
  address public membershipFactory;
  address public rendererImpl;
  address public membershipImpl;
  address public paymentModuleImpl;

  function setUp() public {
    startHoax(address(1));
    rendererImpl = address(new Renderer(address(1), "https://tokens.station.express"));
    membershipImpl = address(new Membership());
    membershipFactory = address(new MembershipFactory(membershipImpl, address(1)));
    paymentModuleImpl = address(new FixedETHPurchaseModule());
    vm.stopPrank();
  }

  // meaning: I shouldn't be able to mint if I'm not the owner of the contract
  // I shouldn't be able to mint without the module as a non-owner
  function test_mint_without_adding_payment_module_should_fail() public {
    startHoax(address(2));
    address membership = MembershipFactory(membershipFactory).create(address(1), rendererImpl, "Friends of Station", "FRIENDS");
    Membership membershipContract = Membership(membership);

    vm.expectRevert("NOT_PERMITTED");
    membershipContract.mintTo(address(2));
    vm.stopPrank();
  }

  function test_add_module_and_mint() public {
    startHoax(address(1));
    address membership = MembershipFactory(membershipFactory).create(address(1), rendererImpl, "Friends of Station", "FRIENDS");
    Membership membershipContract = Membership(membership);
    FixedETHPurchaseModule paymentModule = FixedETHPurchaseModule(paymentModuleImpl);
    paymentModule.setup(membership, membership, 1);
    membershipContract.addMintModule(paymentModuleImpl);

    paymentModule.mint{value: 1}(membership);

    assertEq(membershipContract.ownerOf(0), address(1));
    vm.stopPrank();
  }
}
