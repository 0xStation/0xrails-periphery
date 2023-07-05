// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";
import {FixedETHPurchaseModule} from "src/membership/modules/FixedETHPurchaseModule.sol";

// designed to make sure the payment module itself is working properly.
// different than TestPaymentModule which is designed to test if payment module can be added to a membership
// and work correctly with the membership.
contract PaymentModuleInitTest is Test, SetUpMembership {
    FixedETHPurchaseModule paymentModule;
    Membership public collectionProxy;

    uint256 fee;
    uint256 price;

    function setUp() public override {
        // deploy payment module
        owner = address(1);
        fee =  0.0007 ether;
        price = 0.1 ether;
        paymentModule = new FixedETHPurchaseModule(owner, fee);

        // deploy Membership proxy
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        collectionProxy = SetUpMembership.create();
    }

    // sanity checks on configuring a collection and permissions
    function test_addAddress() public {
        // assert module owner can set price for a collection
        vm.prank(owner);
        paymentModule.setup(address(collectionProxy), price);
        uint256 initialPrice = paymentModule.prices(address(collectionProxy));
        assertEq(initialPrice, price);

        // assert collection can change its own price
        uint256 newPrice = 0.2 ether;
        vm.prank(address(collectionProxy));
        paymentModule.setup(address(collectionProxy), newPrice);
        uint256 updatedPrice = paymentModule.prices(address(collectionProxy));
        assertEq(updatedPrice, newPrice);

        // assert module owner can change fee
        uint256 newFee = 0.0001 ether;
        vm.prank(paymentModule.owner());
        paymentModule.updateFee(newFee);
        assertEq(paymentModule.fee(), newFee);
    }

    function test_mint() public {
        //TODO
    }
}
