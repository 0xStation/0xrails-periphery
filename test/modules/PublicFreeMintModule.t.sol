// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {FreeMintModuleV3} from "src/membership/modules/FreeMintModuleV3.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract FreeMintModuleTest is Test, SetUpMembership {
    Membership public proxy;
    FreeMintModuleV3 public module;

    function setUp() public override {
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        proxy = SetUpMembership.create();
    }

    // helper function to initialize Modules for each test function
    // @note Not invoked as a standalone test
    function initModule(uint64 fee) public {
        module = new FreeMintModuleV3(owner, fee);
        // enable grants in module config setup and give module mint permission on proxy
        vm.startPrank(owner);
        module.setUp(address(proxy), false);
        proxy.permit(address(module), operationPermissions(Permissions.Operation.MINT));
    }

    function test_mint(uint64 fee, uint64 balanceOffset) public {
        initModule(fee);

        address recipient = createAccount();

        uint256 initialBalance = uint256(fee) + uint256(balanceOffset); // cast to prevent overflow
        vm.deal(recipient, initialBalance);

        vm.startPrank(recipient);
        // mint token
        uint256 tokenId = module.mint{value: fee}(address(proxy));
        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
        assertEq(recipient.balance, balanceOffset);
    }

    function test_mint_revertIf_invalidFee(uint64 fee, uint64 balanceOffset) public {
        vm.assume(fee > 0);
        initModule(fee);

        address recipient = createAccount();

        uint256 initialBalance = uint256(fee) + uint256(balanceOffset); // cast to prevent overflow
        vm.deal(recipient, initialBalance);

        vm.startPrank(recipient);
        // mint token (reverts)
        // note `fee - 1` msg.value
        vm.expectRevert("INVALID_FEE");
        module.mint{value: fee - 1}(address(proxy));
        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
    }

    function test_mintTo(uint64 fee, uint64 balanceOffset) public {
        initModule(fee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 initialBalance = uint256(fee) + uint256(balanceOffset); // cast to prevent overflow
        vm.deal(payer, initialBalance);

        vm.startPrank(payer);
        // mint token
        uint256 tokenId = module.mintTo{value: fee}(address(proxy), recipient);
        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
        assertEq(payer.balance, balanceOffset);
    }

    function test_mintTo_revertIf_invalidFee(uint64 fee, uint64 balanceOffset) public {
        vm.assume(fee > 0);
        initModule(fee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 initialBalance = uint256(fee) + uint256(balanceOffset); // cast to prevent overflow
        vm.deal(payer, initialBalance);

        vm.startPrank(payer);
        // mint token (reverts)
        // note `fee - 1` msg.value
        vm.expectRevert("INVALID_FEE");
        module.mintTo{value: fee - 1}(address(proxy), recipient);
        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(payer.balance, initialBalance);
    }
}
