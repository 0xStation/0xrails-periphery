// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/lib/renderer/Renderer.sol";
import "../src/membership/Membership.sol";
import "../src/membership/MembershipFactory.sol";
import "../src/modules/Payment.sol";

// designed to make sure the payment module itself is working properly.
// different than TestPaymentModule which is designed to test if payment module can be added to a membership
// and work correctly with the membership.
contract PaymentModuleInitTest is Test {
  PaymentModule paymentModule;

  function setUp() public {
    paymentModule = new PaymentModule();
  }

  function test_add_address() public {
    paymentModule.addCollection(address(0), 1);
    // nothing exploded!
  }
}
