// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {GasCoinPurchaseModuleV4} from "src/v2/membership/modules/GasCoinPurchaseModule.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract GasCoinPurchaseModuleV4Test is Test, SetUpMembership {
    Membership public proxy;
    GasCoinPurchaseModuleV4 public gasCoinModule;
    FeeManager public feeManager;

    // intended to contain custom error signatures
    bytes public err;

    // transplanted from ModuleFeeV2 since custom errors are not externally visible
    error InvalidFee(uint256 expected, uint256 received);

    function setUp() public override {
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        proxy = SetUpMembership.create();
    }

    // helper function to initialize Modules for each test function
    // @note Not invoked as a standalone test
    function initModule(uint120 baseFee, uint120 variableFee, uint256 price) public {
        // instantiate feeManager with fuzzed base and variable fees as baseline
        FeeManager.Fees memory exampleFees = FeeManager.Fees(FeeManager.FeeSetting.Free, baseFee, variableFee);
        feeManager = new FeeManager(owner, exampleFees, exampleFees);

        gasCoinModule = new GasCoinPurchaseModuleV4(owner, address(feeManager));

        // enable grants in module config setup and give module mint permission on proxy
        vm.startPrank(owner);
        gasCoinModule.setUp(address(proxy), price, false);
        proxy.permit(address(gasCoinModule), operationPermissions(Permissions.Operation.MINT));
    }

    function test_mint(uint120 baseFee, uint120 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint120).max && price > type(uint136).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint136).max);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();

        uint256 quantity = 1; //single mint
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;
        vm.deal(recipient, totalCost);

        vm.startPrank(recipient);
        // mint token
        uint256 tokenId = gasCoinModule.mint{value: totalCost}(address(proxy));

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
    }

    function test_mintRevertInvalidFee(uint120 baseFee, uint120 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint120).max && price > type(uint136).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint136).max);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();

        uint256 quantity = 1; //single mint
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        // calculate correct msg.value for expected revert error
        uint256 totalCost = price * quantity + fee;
        // craft wrong msg.value
        uint256 wrongTotalCost = totalCost - 1;
        vm.deal(recipient, wrongTotalCost);
        // snapshot balance to ensure unchanged after reverted mint attempt
        uint256 initialBalance = recipient.balance;

        vm.startPrank(recipient);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        uint256 tokenId = gasCoinModule.mint{value: wrongTotalCost}(address(proxy));

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
    }

    function test_mintTo(uint120 baseFee, uint120 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint120).max && price > type(uint136).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint136).max);
        initModule(baseFee, variableFee, price);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 quantity = 1; //single mint
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;

        vm.deal(payer, totalCost);
        uint256 initialBalance = payer.balance;

        vm.startPrank(payer);
        // mint token
        uint256 tokenId = gasCoinModule.mintTo{value: totalCost}(address(proxy), recipient);

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
        assertEq(payer.balance, initialBalance - totalCost);
    }

    function test_mintToRevertInvalidFee(uint120 baseFee, uint120 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint120).max && price > type(uint136).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint136).max);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();

        uint256 quantity = 1; //single mint
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        // calculate correct msg.value for expected revert error
        uint256 totalCost = price * quantity + fee;
        // craft wrong msg.value
        uint256 wrongTotalCost = totalCost - 1;
        vm.deal(recipient, wrongTotalCost);
        // snapshot balance to ensure unchanged after reverted mint attempt
        uint256 initialBalance = recipient.balance;

        vm.startPrank(recipient);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        uint256 tokenId = gasCoinModule.mintTo{value: wrongTotalCost}(address(proxy), recipient);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
    }

    function test_batchMint(uint120 baseFee, uint120 variableFee, uint256 price, uint8 _quantity) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint120).max && price > type(uint120).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint120).max);
        vm.assume(_quantity != 0);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();
        uint256 quantity = _quantity;
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;
        vm.deal(recipient, totalCost);

        vm.startPrank(recipient);
        // mint token
        (uint256 startTokenId, uint256 endTokenId) = gasCoinModule.batchMint{value: totalCost}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < endTokenId - startTokenId; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), quantity);
    }

    function test_batchMintRevertInvalidFee(uint120 baseFee, uint120 variableFee, uint256 price, uint8 _quantity)
        public
    {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint120).max && price > type(uint120).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint120).max);
        vm.assume(_quantity != 0);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();
        uint256 quantity = _quantity;
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        // calculate correct msg.value for expected revert error
        uint256 totalCost = price * quantity + fee;
        // craft wrong msg.value
        uint256 wrongTotalCost = totalCost - 1;
        vm.deal(recipient, wrongTotalCost);
        // snapshot balance to ensure unchanged after reverted mint attempt
        uint256 initialBalance = recipient.balance;

        vm.startPrank(recipient);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        gasCoinModule.batchMint{value: wrongTotalCost}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
    }

    function test_batchMintTo(uint120 baseFee, uint120 variableFee, uint256 price, uint8 _quantity) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint120).max && price > type(uint120).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint120).max);
        vm.assume(_quantity != 0);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();
        address payer = createAccount();
        uint256 quantity = _quantity;
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;
        vm.deal(payer, totalCost);
        uint256 initialBalance = payer.balance;

        vm.startPrank(payer);
        // mint token
        (uint256 startTokenId, uint256 endTokenId) =
            gasCoinModule.batchMintTo{value: totalCost}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < endTokenId - startTokenId; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), quantity);
        assertEq(payer.balance, initialBalance - totalCost);
    }

    function test_batchMintToRevertInvalidFee(uint120 baseFee, uint120 variableFee, uint256 price, uint8 _quantity)
        public
    {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint120).max && price > type(uint120).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint120).max);
        vm.assume(_quantity != 0);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();
        address payer = createAccount();
        uint256 quantity = _quantity;
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        // calculate correct msg.value for expected revert error
        uint256 totalCost = price * quantity + fee;
        // craft wrong msg.value
        uint256 wrongTotalCost = totalCost - 1;
        vm.deal(payer, wrongTotalCost);
        // snapshot balance to ensure unchanged after reverted mint attempt
        uint256 initialBalance = payer.balance;

        vm.startPrank(payer);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        gasCoinModule.batchMintTo{value: wrongTotalCost}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(payer.balance, initialBalance);
    }
}
