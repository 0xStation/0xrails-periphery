// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/lib/renderer/Renderer.sol";
import "src/membership/MembershipFactory.sol";
import "src/membership/modules/ETHPurchaseModule.sol";

// designed to make sure the payment module itself is working properly.
// different than TestPaymentModule which is designed to test if payment module can be added to a membership
// and work correctly with the membership.
contract PaymentModuleInitTest is Test {
    ETHPurchaseModule paymentModule;

    function setUp() public {
        paymentModule = new ETHPurchaseModule(address(1), 0.0007 ether);
    }

    function test_add_address() public {
        // TODO
    }
}
