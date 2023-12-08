// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {Operations} from "0xrails/lib/Operations.sol";

import {GasCoinPurchaseController} from "src/membership/modules/GasCoinPurchaseController.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract GasCoinPurchaseControllerTest is Test, SetUpMembership {
    ERC721Rails public proxy;
    GasCoinPurchaseController public gasCoinPurchaseController;
    FeeManager public feeManager;

    // intended to contain custom error signatures
    bytes public err;

    // transplanted from FeeControllerV2 since custom errors are not externally visible
    error InvalidFee(uint256 expected, uint256 received);

    function setUp() public override {
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        proxy = SetUpMembership.create();
    }

    // helper function to initialize Modules for each test function
    // @note Not invoked as a standalone test
    function initModule(uint96 baseFee, uint96 variableFee, uint256 price) public {
        // instantiate feeManager with fuzzed base and variable fees as baseline
        feeManager = new FeeManager(owner, baseFee, variableFee, baseFee, variableFee);

        // forwarder not in scope of these tests
        gasCoinPurchaseController = new GasCoinPurchaseController(owner, address(feeManager), address(0x0));

        // setup module, give module mint permission, add payout address
        vm.startPrank(owner);
        gasCoinPurchaseController.setUp(address(proxy), price, false);
        proxy.addPermission(Operations.MINT, address(gasCoinPurchaseController));
        PayoutAddressExtension(address(proxy)).updatePayoutAddress(payoutAddress);
        vm.stopPrank();
    }

    function test_mint(uint96 baseFee, uint96 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint96).max && price > type(uint136).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint136).max);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();

        uint256 quantity = 1; //single mint
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;
        vm.deal(recipient, totalCost);
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(recipient);
        // mint token
        gasCoinPurchaseController.mint{value: totalCost}(address(proxy));
        uint256 tokenId = proxy.totalSupply();

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
        assertEq(payoutAddress.balance, payoutInitialBalance + price);
    }

    function test_mintRevertInvalidFee(uint96 baseFee, uint96 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint96).max && price > type(uint136).max` but that's more than ETH in existence
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
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(recipient);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        gasCoinPurchaseController.mint{value: wrongTotalCost}(address(proxy));

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
        assertEq(payoutAddress.balance, payoutInitialBalance);
    }

    function test_mintTo(uint96 baseFee, uint96 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint96).max && price > type(uint136).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint136).max);
        initModule(baseFee, variableFee, price);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 quantity = 1; //single mint
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;

        vm.deal(payer, totalCost);
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(payer);
        // mint token
        gasCoinPurchaseController.mintTo{value: totalCost}(address(proxy), recipient);
        uint256 tokenId = proxy.totalSupply();

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
        assertEq(payoutAddress.balance, payoutInitialBalance + price);
    }

    function test_mintToRevertInvalidFee(uint96 baseFee, uint96 variableFee, uint256 price) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees & price:
        // ie `fees ~= type(uint96).max && price > type(uint136).max` but that's more than ETH in existence
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
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(recipient);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        gasCoinPurchaseController.mintTo{value: wrongTotalCost}(address(proxy), recipient);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
        assertEq(payoutAddress.balance, payoutInitialBalance);
    }

    function test_batchMint(uint96 baseFee, uint96 variableFee, uint256 price, uint8 _quantity) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint96).max && price > type(uint96).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint96).max);
        vm.assume(_quantity != 0);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();
        uint256 quantity = _quantity;
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;
        vm.deal(recipient, totalCost);
        uint256 initialSupply = proxy.totalSupply();
        uint256 startTokenId = initialSupply + 1;
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(recipient);
        // mint token
        gasCoinPurchaseController.batchMint{value: totalCost}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < quantity; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), quantity);
        assertEq(payoutAddress.balance, payoutInitialBalance + price * quantity);
    }

    function test_batchMintRevertInvalidFee(uint96 baseFee, uint96 variableFee, uint256 price, uint8 _quantity)
        public
    {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint96).max && price > type(uint96).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint96).max);
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
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(recipient);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        gasCoinPurchaseController.batchMint{value: wrongTotalCost}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
        assertEq(payoutAddress.balance, payoutInitialBalance);
    }

    function test_batchMintTo(uint96 baseFee, uint96 variableFee, uint256 price, uint8 _quantity) public {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint96).max && price > type(uint96).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint96).max);
        vm.assume(_quantity != 0);
        initModule(baseFee, variableFee, price);

        address recipient = createAccount();
        address payer = createAccount();
        uint256 quantity = _quantity;
        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, price);
        uint256 totalCost = price * quantity + fee;
        vm.deal(payer, totalCost);
        uint256 initialSupply = proxy.totalSupply();
        uint256 startTokenId = initialSupply + 1;
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(payer);
        // mint token
        gasCoinPurchaseController.batchMintTo{value: totalCost}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < quantity; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), quantity);
        assertEq(payoutAddress.balance, payoutInitialBalance + price * quantity);
    }

    function test_batchMintToRevertInvalidFee(uint96 baseFee, uint96 variableFee, uint256 price, uint8 _quantity)
        public
    {
        // FeeManager.getFeeTotals can overflow but only on impossibly high fees, price, _quantity:
        // ie `fees ~= type(uint96).max && price > type(uint96).max && _quantity > type(uint16).max` but that's more than ETH in existence
        price = bound(price, 1, type(uint96).max);
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
        uint256 payoutInitialBalance = payoutAddress.balance;

        vm.startPrank(payer);
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, totalCost, wrongTotalCost);
        vm.expectRevert(err);
        gasCoinPurchaseController.batchMintTo{value: wrongTotalCost}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(payer.balance, initialBalance);
        assertEq(payoutAddress.balance, payoutInitialBalance);
    }
}
