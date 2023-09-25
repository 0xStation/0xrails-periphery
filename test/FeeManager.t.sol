// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
// src
import {Test} from "forge-std/Test.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract FeeManagerTest is Test, SetUpMembership {
    struct TestParams {
        uint120 baseFee;
        uint120 variableFee;
        uint120 ethBaseFee;
        uint120 ethVariableFee;
    }

    FeeManager public feeManager;
    ERC721Rails public proxy;

    // intended to contain custom error signatures
    bytes public err;

    error FeesNotSet();

    function setUp() public override {
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        proxy = SetUpMembership.create();
    }

    function test_constructor(TestParams memory testParams) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // assert owner was set
        assertEq(feeManager.owner(), address(0xbeefbabe));

        FeeManager.Fees memory exampleFees = FeeManager.Fees(true, testParams.baseFee, testParams.variableFee);
        // assert defaultFees were set
        FeeManager.Fees memory defaultFees = feeManager.getDefaultFees();
        assertTrue(defaultFees.exist);
        assertEq(defaultFees.baseFee, exampleFees.baseFee);
        assertEq(defaultFees.variableFee, exampleFees.variableFee);

        FeeManager.Fees memory ethFees = FeeManager.Fees(true, testParams.ethBaseFee, testParams.ethVariableFee);
        // assert ethFees were set
        FeeManager.Fees memory tokenFees = feeManager.getTokenFees(address(0x0));
        assertTrue(tokenFees.exist);
        assertEq(tokenFees.baseFee, ethFees.baseFee);
        assertEq(tokenFees.variableFee, ethFees.variableFee);
    }

    function test_setDefaultFees(TestParams memory testParams) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        vm.prank(feeManager.owner());
        feeManager.setDefaultFees(0, 0);

        FeeManager.Fees memory newFees = feeManager.getDefaultFees();
        assertTrue(newFees.exist);
        assertEq(newFees.baseFee, 0);
        assertEq(newFees.variableFee, 0);
    }

    function test_setDefaultFeesRevertOnlyOwner(TestParams memory testParams) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        err = bytes("Ownable: caller is not the owner");
        vm.expectRevert(err);
        feeManager.setDefaultFees(0, 0);
    }

    function test_setTokenFees(TestParams memory testParams, address tokenAddress) public {
        vm.assume(tokenAddress != address(0x0));
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure tokenFees are not set for tokenAddress
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getTokenFees(tokenAddress);

        // set token fees and change eth fees
        FeeManager.Fees memory mintFees = FeeManager.Fees(true, testParams.baseFee, testParams.variableFee);
        vm.startPrank(feeManager.owner());
        feeManager.setTokenFees(tokenAddress, testParams.baseFee, testParams.variableFee);
        feeManager.setTokenFees(address(0x0), testParams.baseFee, testParams.variableFee);

        FeeManager.Fees memory newFees = feeManager.getTokenFees(tokenAddress);
        assertTrue(newFees.exist);
        assertEq(newFees.baseFee, mintFees.baseFee);
        assertEq(newFees.variableFee, mintFees.variableFee);

        FeeManager.Fees memory newEthFees = feeManager.getTokenFees(address(0x0));
        assertTrue(newEthFees.exist);
        assertEq(newEthFees.baseFee, mintFees.baseFee);
        assertEq(newEthFees.variableFee, mintFees.variableFee);
    }

    function test_setTokenFeesRevertOnlyOwner(TestParams memory testParams, address tokenAddress) public {
        vm.assume(tokenAddress != address(0x0));
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure tokenFees are not set for tokenAddress
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getTokenFees(tokenAddress);

        err = bytes("Ownable: caller is not the owner");
        vm.expectRevert(err);
        feeManager.setTokenFees(tokenAddress, testParams.baseFee, testParams.variableFee);
        vm.expectRevert(err);
        feeManager.setTokenFees(address(0x0), testParams.baseFee, testParams.variableFee);
    }

    function test_getTokenFeesRevertNotSet(TestParams memory testParams, address tokenAddress) public {
        vm.assume(tokenAddress != address(0x0)); // eth tokenFees are set in constructor
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure tokenFees are not set for tokenAddress and a random neighbor address
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getTokenFees(tokenAddress);
        vm.expectRevert(err);
        feeManager.getTokenFees(address(uint160(tokenAddress) + 1));
    }

    function test_setCollectionFees(
        TestParams memory testParams,
        TestParams memory collectionParams,
        address tokenAddress
    ) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure collectionFees are not set for tokenAddress or eth
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), tokenAddress);
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), address(0x0));

        // set token fees and eth fees
        vm.startPrank(feeManager.owner());
        feeManager.setCollectionFees(
            address(proxy), tokenAddress, collectionParams.baseFee, collectionParams.variableFee
        );
        feeManager.setCollectionFees(
            address(proxy), address(0x0), collectionParams.baseFee, collectionParams.variableFee
        );

        FeeManager.Fees memory newCollectionFees = feeManager.getCollectionFees(address(proxy), tokenAddress);
        assertTrue(newCollectionFees.exist);
        assertEq(newCollectionFees.baseFee, collectionParams.baseFee);
        assertEq(newCollectionFees.variableFee, collectionParams.variableFee);

        FeeManager.Fees memory newEthCollectionFees = feeManager.getCollectionFees(address(proxy), address(0x0));
        assertTrue(newEthCollectionFees.exist);
        assertEq(newEthCollectionFees.baseFee, collectionParams.baseFee);
        assertEq(newEthCollectionFees.variableFee, collectionParams.variableFee);
    }

    function test_setCollectionFeesRevertOnlyOwner(
        TestParams memory testParams,
        TestParams memory collectionParams,
        address tokenAddress
    ) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure collectionFees are not set for tokenAddress or eth
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), tokenAddress);
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), address(0x0));

        err = bytes("Ownable: caller is not the owner");
        vm.expectRevert(err);
        feeManager.setCollectionFees(
            address(proxy), tokenAddress, collectionParams.baseFee, collectionParams.variableFee
        );
        vm.expectRevert(err);
        feeManager.setCollectionFees(
            address(proxy), address(0x0), collectionParams.baseFee, collectionParams.variableFee
        );
    }

    function test_getCollectionFeesRevertNotSet(TestParams memory testParams, address tokenAddress) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure collectionFees are not set for tokenAddress, a neighboring address, or eth
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), tokenAddress);
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), address(uint160(tokenAddress) + 1));
        vm.expectRevert(err);
        feeManager.getCollectionFees(address(proxy), address(0x0));
    }

    // getFeeTotals tests split into 3 for `stack too deep` errors
    function test_getFeeTotalsBaseline(
        TestParams memory testParams,
        TestParams memory collectionParams,
        address tokenAddress,
        uint16 quantity,
        uint96 unitPrice
    ) public {
        vm.assume(tokenAddress != address(0x0));
        _constrainFuzzInputs(
            testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee
        );
        _constrainFuzzInputs(
            collectionParams.baseFee,
            collectionParams.variableFee,
            collectionParams.ethBaseFee,
            collectionParams.ethVariableFee
        );

        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        address someRecipient = address(0xdeadbeef);

        // calculate feeTotal using defaultFees
        uint256 erc20FeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedErc20FeeTotal = uint256(quantity) * uint256(testParams.baseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(testParams.variableFee) / 10_000);
        assertEq(erc20FeeTotal, expectedErc20FeeTotal);
    }

    function test_getFeeTotalsDefault(
        TestParams memory testParams,
        TestParams memory tokenParams,
        TestParams memory collectionParams,
        address tokenAddress,
        uint16 quantity,
        uint96 unitPrice
    ) public {
        vm.assume(tokenAddress != address(0x0));
        _constrainFuzzInputs(
            testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee
        );
        _constrainFuzzInputs(
            collectionParams.baseFee,
            collectionParams.variableFee,
            collectionParams.ethBaseFee,
            collectionParams.ethVariableFee
        );

        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        address someRecipient = address(0xdeadbeef);

        // calculate feeTotal using eth tokenFees
        uint256 ethFeeTotal = feeManager.getFeeTotals(address(proxy), address(0x0), someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedEthFeeTotal = uint256(quantity) * uint256(testParams.ethBaseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(testParams.ethVariableFee) / 10_000);
        assertEq(ethFeeTotal, expectedEthFeeTotal);

        // set erc20 tokenFees
        vm.prank(feeManager.owner());
        feeManager.setTokenFees(tokenAddress, tokenParams.baseFee, tokenParams.variableFee);

        // calculate feeTotal using erc20 tokenFees
        uint256 erc20DefaultFeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedErc20DefaultFeeTotal = uint256(quantity) * uint256(tokenParams.baseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(tokenParams.variableFee) / 10_000);
        assertEq(erc20DefaultFeeTotal, expectedErc20DefaultFeeTotal);
    }

    function test_getFeeTotalsCollection(
        TestParams memory testParams,
        TestParams memory collectionParams,
        address tokenAddress,
        uint16 quantity,
        uint96 unitPrice
    ) public {
        vm.assume(tokenAddress != address(0x0));
        _constrainFuzzInputs(
            testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee
        );
        _constrainFuzzInputs(
            collectionParams.baseFee,
            collectionParams.variableFee,
            collectionParams.ethBaseFee,
            collectionParams.ethVariableFee
        );

        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        address someRecipient = address(0xdeadbeef);

        vm.prank(feeManager.owner());
        feeManager.setTokenFees(tokenAddress, collectionParams.baseFee, collectionParams.variableFee);

        // calculate feeTotal using erc20 collectionFees
        uint256 erc20CollectionFeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedErc20CollectionFeeTotal = uint256(quantity) * uint256(collectionParams.baseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(collectionParams.variableFee) / 10_000);
        assertEq(erc20CollectionFeeTotal, expectedErc20CollectionFeeTotal);

        // set eth collectionFees
        vm.prank(feeManager.owner());
        feeManager.setTokenFees(tokenAddress, collectionParams.ethBaseFee, collectionParams.ethVariableFee);

        // calculate feeTotal using eth collectionFees
        uint256 ethCollectionFeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedEthCollectionFeeTotal = uint256(quantity) * uint256(collectionParams.ethBaseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(collectionParams.ethVariableFee) / 10_000);
        assertEq(ethCollectionFeeTotal, expectedEthCollectionFeeTotal);
    }

    /*============
        HELPERS
    ============*/

    function deployWithFuzz(uint120 baseFee, uint120 variableFee, uint120 ethBaseFee, uint120 ethVariableFee) public {
        address owner = address(0xbeefbabe);
        feeManager = new FeeManager(owner, baseFee, variableFee, ethBaseFee, ethVariableFee);
    }

    // function to constrain fuzzed test values to realistic values for performance
    // FeeManager.getFeeTotals() can overflow due to arithmetic in StablecoinPurchaseController.mintPriceToStablecoinAmount()
    // but only on impossibly high fees, price, & decimals causing a revert, roughly:
    // if (1ecoinDecimals * 1emoduleDecimals * _baseFee * _variableFee * _price > type(uint256).max)
    function _constrainFuzzInputs(uint120 _baseFee, uint120 _variableFee, uint120 _ethBaseFee, uint120 _ethVariableFee)
        // uint128 _price
        internal
        pure
    {
        // disallow extreme price && fee values to prevent decimal handling from overflowing
        // vm.assume(_price > 0 && _price < type(uint96).max);
        vm.assume(_baseFee < type(uint64).max);
        vm.assume(_variableFee < type(uint64).max);
        vm.assume(_ethBaseFee < type(uint64).max);
        vm.assume(_ethVariableFee < type(uint64).max);
    }
}
