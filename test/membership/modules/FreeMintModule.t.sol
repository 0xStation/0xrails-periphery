// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {Operations} from "0xrails/lib/Operations.sol";

import {FreeMintController} from "src/membership/modules/FreeMintController.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract FreeMintControllerTest is Test, SetUpMembership {
    ERC721Rails public proxy;
    FreeMintController public module;
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
    function initModule(uint96 baseFee, uint96 variableFee) public {
        // instantiate feeManager with fuzzed base and variable fees as baseline
        feeManager = new FeeManager(owner, baseFee, variableFee, baseFee, variableFee);

        module = new FreeMintController(owner, address(feeManager), address(metadataRouter));

        // enable grants in module config setup and give module mint permission on proxy
        vm.startPrank(owner);
        module.setUp(address(proxy), false);
        proxy.addPermission(Operations.MINT, address(module));
        vm.stopPrank();
    }

    function test_mint(uint96 baseFee, uint96 variableFee) public {
        initModule(baseFee, variableFee);

        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, 1, 0);
        vm.deal(recipient, fee);

        vm.startPrank(recipient);
        // mint token
        module.mint{value: fee}(address(proxy));
        uint256 tokenId = proxy.totalSupply();

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
    }

    function test_mintRevertInvalidFee(uint96 baseFee, uint96 variableFee) public {
        initModule(baseFee, variableFee);

        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, 1, 0);
        vm.deal(recipient, fee + 1); // + 1 to handle waived fee case where wrongFee must be set to 1 if fee == 0
        uint256 initialBalance = recipient.balance;

        vm.startPrank(recipient);
        // create a wrong msg.value: `fee - 1` unless fee == 0, then `fee + 1`
        uint256 wrongFee = fee == 0 ? fee + 1 : fee - 1;
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, fee, wrongFee);
        vm.expectRevert(err);
        module.mint{value: wrongFee}(address(proxy));

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
    }

    function test_mintTo(uint96 baseFee, uint96 variableFee) public {
        initModule(baseFee, variableFee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, 1, 0);
        vm.deal(payer, fee);

        vm.startPrank(payer);
        // mint token
        module.mintTo{value: fee}(address(proxy), recipient);
        uint256 tokenId = proxy.totalSupply();

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
    }

    function test_mintToRevertInvalidFee(uint96 baseFee, uint96 variableFee) public {
        initModule(baseFee, variableFee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, 1, 0);
        vm.deal(payer, fee + 1); // + 1 to handle waived fee case where wrongFee must be set to 1 if fee == 0
        uint256 initialBalance = payer.balance;

        vm.startPrank(payer);
        // create a wrong msg.value: `fee - 1` unless fee == 0, then `fee + 1`
        uint256 wrongFee = fee == 0 ? fee + 1 : fee - 1;
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, fee, wrongFee);
        vm.expectRevert(err);
        module.mintTo{value: wrongFee}(address(proxy), recipient);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(payer.balance, initialBalance);
    }

    function test_batchMint(uint96 baseFee, uint96 variableFee, uint8 _quantity) public {
        // bounded fuzz inputs to a smaller range for performance, tests pass even for `uint64 _quantity`
        vm.assume(_quantity != 0);
        // bound cheatcode took too long so recasting works fine
        uint256 quantity = uint256(_quantity);
        initModule(baseFee, variableFee);

        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, 0);
        vm.deal(recipient, fee);
        uint256 initialBalance = recipient.balance;
        uint256 initialSupply = proxy.totalSupply();
        uint256 startTokenId = initialSupply + 1;

        vm.startPrank(recipient);
        module.batchMint{value: fee}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < quantity; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), initialSupply + quantity);
        assertEq(recipient.balance, initialBalance - fee);
    }

    function test_batchMintRevertInvalidFee(uint96 baseFee, uint96 variableFee, uint8 _quantity) public {
        // bounded fuzz inputs to a smaller range for performance, tests pass even for `uint64 _quantity`
        vm.assume(_quantity != 0);
        // bound cheatcode took too long so recasting works fine
        uint256 quantity = uint256(_quantity);
        initModule(baseFee, variableFee);

        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, 0);
        vm.deal(recipient, fee + 1); // + 1 to handle waived fee case where wrongFee must be set to 1 if fee == 0
        uint256 initialBalance = recipient.balance;

        vm.startPrank(recipient);
        // create a wrong msg.value: `fee - 1` unless fee == 0, then `fee + 1`
        uint256 wrongFee = fee == 0 ? fee + 1 : fee - 1;
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, fee, wrongFee);
        vm.expectRevert(err);
        module.batchMint{value: wrongFee}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(recipient.balance, initialBalance);
    }

    function test_batchMintTo(uint96 baseFee, uint96 variableFee, uint8 _quantity) public {
        // bounded fuzz inputs to a smaller range for performance, tests pass even for `uint64 _quantity`
        vm.assume(_quantity != 0);
        // bound cheatcode took too long so recasting works fine
        uint256 quantity = uint256(_quantity);
        initModule(baseFee, variableFee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, 0);
        vm.deal(payer, fee);
        uint256 initialBalance = payer.balance;
        uint256 initialSupply = proxy.totalSupply();
        uint256 startTokenId = initialSupply + 1;

        vm.startPrank(payer);
        module.batchMintTo{value: fee}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < quantity; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), initialSupply + quantity);
        assertEq(recipient.balance, initialBalance - fee);
    }

    function test_batchMintToRevertInvalidFee(uint96 baseFee, uint96 variableFee, uint8 _quantity) public {
        // bounded fuzz inputs to a smaller range for performance, tests pass even for `uint64 _quantity`
        vm.assume(_quantity != 0);
        // bound cheatcode took too long so recasting works fine
        uint256 quantity = uint256(_quantity);
        initModule(baseFee, variableFee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, 0);
        vm.deal(payer, fee + 1);
        uint256 initialBalance = payer.balance;

        vm.startPrank(payer);
        // create a wrong msg.value: `fee - 1` unless fee == 0, then `fee + 1`
        uint256 wrongFee = fee == 0 ? fee + 1 : fee - 1;
        // mint token (reverts)
        err = abi.encodeWithSelector(InvalidFee.selector, fee, wrongFee);
        vm.expectRevert(err);
        module.batchMintTo{value: wrongFee}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), 0);
        assertEq(proxy.totalSupply(), 0);
        assertEq(payer.balance, initialBalance);
    }
}
