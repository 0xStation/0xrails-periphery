// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721Mage} from "mage/cores/ERC721/ERC721Mage.sol";
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
    ERC721Mage public proxy;

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

        FeeManager.Fees memory exampleFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, testParams.baseFee, testParams.variableFee);
        // assert baselineFees were set
        FeeManager.Fees memory baselineFees = feeManager.getBaselineFees();
        assertEq(uint8(baselineFees.setting), uint8(exampleFees.setting));
        assertEq(baselineFees.baseFee, exampleFees.baseFee);
        assertEq(baselineFees.variableFee, exampleFees.variableFee);

        FeeManager.Fees memory ethFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, testParams.ethBaseFee, testParams.ethVariableFee);
        // assert ethFees were set
        FeeManager.Fees memory defaultFees = feeManager.getDefaultFees(address(0x0));
        assertEq(uint8(defaultFees.setting), uint8(ethFees.setting));
        assertEq(defaultFees.baseFee, ethFees.baseFee);
        assertEq(defaultFees.variableFee, ethFees.variableFee);
    }

    function test_setBaselineFees(TestParams memory testParams) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        FeeManager.Fees memory freeMintFees = FeeManager.Fees(FeeManager.FeeSetting.Free, 0, 0);
        vm.prank(feeManager.owner());
        feeManager.setBaselineFees(freeMintFees);

        FeeManager.Fees memory newFees = feeManager.getBaselineFees();
        assertEq(uint8(newFees.setting), uint8(freeMintFees.setting));
        assertEq(newFees.baseFee, freeMintFees.baseFee);
        assertEq(newFees.variableFee, freeMintFees.variableFee);
    }

    function test_setBaselineFeesRevertOnlyOwner(TestParams memory testParams) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        FeeManager.Fees memory freeMintFees = FeeManager.Fees(FeeManager.FeeSetting.Free, 0, 0);
        err = bytes("Ownable: caller is not the owner");
        vm.expectRevert(err);
        feeManager.setBaselineFees(freeMintFees);
    }

    function test_setDefaultFees(TestParams memory testParams, address tokenAddress) public {
        vm.assume(tokenAddress != address(0x0));
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure defaultFees are not set for tokenAddress
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getDefaultFees(tokenAddress);

        // set token fees and change eth fees
        FeeManager.Fees memory mintFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, testParams.baseFee, testParams.variableFee);
        vm.startPrank(feeManager.owner());
        feeManager.setDefaultFees(tokenAddress, mintFees);
        feeManager.setDefaultFees(address(0x0), mintFees);

        FeeManager.Fees memory newFees = feeManager.getDefaultFees(tokenAddress);
        assertEq(uint8(newFees.setting), uint8(mintFees.setting));
        assertEq(newFees.baseFee, mintFees.baseFee);
        assertEq(newFees.variableFee, mintFees.variableFee);

        FeeManager.Fees memory newEthFees = feeManager.getDefaultFees(address(0x0));
        assertEq(uint8(newEthFees.setting), uint8(mintFees.setting));
        assertEq(newEthFees.baseFee, mintFees.baseFee);
        assertEq(newEthFees.variableFee, mintFees.variableFee);
    }

    function test_setDefaultFeesRevertOnlyOwner(TestParams memory testParams, address tokenAddress) public {
        vm.assume(tokenAddress != address(0x0));
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure defaultFees are not set for tokenAddress
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getDefaultFees(tokenAddress);

        FeeManager.Fees memory defaultFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, testParams.baseFee, testParams.variableFee);

        err = bytes("Ownable: caller is not the owner");
        vm.expectRevert(err);
        feeManager.setDefaultFees(tokenAddress, defaultFees);
        vm.expectRevert(err);
        feeManager.setDefaultFees(address(0x0), defaultFees);
    }

    function test_getDefaultFeesRevertNotSet(TestParams memory testParams, address tokenAddress) public {
        vm.assume(tokenAddress != address(0x0)); // eth defaultFees are set in constructor
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure defaultFees are not set for tokenAddress and a random neighbor address
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getDefaultFees(tokenAddress);
        vm.expectRevert(err);
        feeManager.getDefaultFees(address(uint160(tokenAddress) + 1));
    }

    function test_setOverrideFees(TestParams memory testParams, TestParams memory overrideParams, address tokenAddress)
        public
    {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure overrideFees are not set for tokenAddress or eth
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), tokenAddress);
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), address(0x0));

        // set token fees and eth fees
        FeeManager.Fees memory overrideFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, overrideParams.baseFee, overrideParams.variableFee);
        vm.startPrank(feeManager.owner());
        feeManager.setOverrideFees(address(proxy), tokenAddress, overrideFees);
        feeManager.setOverrideFees(address(proxy), address(0x0), overrideFees);

        FeeManager.Fees memory newOverrideFees = feeManager.getOverrideFees(address(proxy), tokenAddress);
        assertEq(uint8(newOverrideFees.setting), uint8(overrideFees.setting));
        assertEq(newOverrideFees.baseFee, overrideFees.baseFee);
        assertEq(newOverrideFees.variableFee, overrideFees.variableFee);

        FeeManager.Fees memory newEthOverrideFees = feeManager.getOverrideFees(address(proxy), address(0x0));
        assertEq(uint8(newEthOverrideFees.setting), uint8(overrideFees.setting));
        assertEq(newEthOverrideFees.baseFee, overrideFees.baseFee);
        assertEq(newEthOverrideFees.variableFee, overrideFees.variableFee);
    }

    function test_setOverrideFeesRevertOnlyOwner(
        TestParams memory testParams,
        TestParams memory overrideParams,
        address tokenAddress
    ) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure overrideFees are not set for tokenAddress or eth
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), tokenAddress);
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), address(0x0));

        FeeManager.Fees memory overrideFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, overrideParams.baseFee, overrideParams.variableFee);

        err = bytes("Ownable: caller is not the owner");
        vm.expectRevert(err);
        feeManager.setOverrideFees(address(proxy), tokenAddress, overrideFees);
        vm.expectRevert(err);
        feeManager.setOverrideFees(address(proxy), address(0x0), overrideFees);
    }

    function test_getOverrideFeesRevertNotSet(TestParams memory testParams, address tokenAddress) public {
        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        // ensure overrideFees are not set for tokenAddress, a neighboring address, or eth
        err = abi.encodeWithSelector(FeesNotSet.selector);
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), tokenAddress);
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), address(uint160(tokenAddress) + 1));
        vm.expectRevert(err);
        feeManager.getOverrideFees(address(proxy), address(0x0));
    }

    // getFeeTotals tests split into 3 for `stack too deep` errors
    function test_getFeeTotalsBaseline(
        TestParams memory testParams,
        TestParams memory defaultParams,
        TestParams memory overrideParams,
        address tokenAddress,
        uint16 quantity,
        uint96 unitPrice
    ) public {
        vm.assume(tokenAddress != address(0x0));
        _constrainFuzzInputs(
            testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee
        );
        _constrainFuzzInputs(
            overrideParams.baseFee, overrideParams.variableFee, overrideParams.ethBaseFee, overrideParams.ethVariableFee
        );

        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        address someRecipient = address(0xdeadbeef);

        // calculate feeTotal using baselineFees
        uint256 erc20FeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedErc20FeeTotal = uint256(quantity) * uint256(testParams.baseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(testParams.variableFee) / 10_000);
        assertEq(erc20FeeTotal, expectedErc20FeeTotal);
    }

    function test_getFeeTotalsDefault(
        TestParams memory testParams,
        TestParams memory defaultParams,
        TestParams memory overrideParams,
        address tokenAddress,
        uint16 quantity,
        uint96 unitPrice
    ) public {
        vm.assume(tokenAddress != address(0x0));
        _constrainFuzzInputs(
            testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee
        );
        _constrainFuzzInputs(
            overrideParams.baseFee, overrideParams.variableFee, overrideParams.ethBaseFee, overrideParams.ethVariableFee
        );

        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        address someRecipient = address(0xdeadbeef);

        // calculate feeTotal using eth defaultFees
        uint256 ethFeeTotal = feeManager.getFeeTotals(address(proxy), address(0x0), someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedEthFeeTotal = uint256(quantity) * uint256(testParams.ethBaseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(testParams.ethVariableFee) / 10_000);
        assertEq(ethFeeTotal, expectedEthFeeTotal);

        // set erc20 defaultFees
        FeeManager.Fees memory defaultFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, defaultParams.baseFee, defaultParams.variableFee);
        vm.prank(feeManager.owner());
        feeManager.setDefaultFees(tokenAddress, defaultFees);

        // calculate feeTotal using erc20 defaultFees
        uint256 erc20DefaultFeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedErc20DefaultFeeTotal = uint256(quantity) * uint256(defaultParams.baseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(defaultParams.variableFee) / 10_000);
        assertEq(erc20DefaultFeeTotal, expectedErc20DefaultFeeTotal);
    }

    function test_getFeeTotalsOverride(
        TestParams memory testParams,
        TestParams memory defaultParams,
        TestParams memory overrideParams,
        address tokenAddress,
        uint16 quantity,
        uint96 unitPrice
    ) public {
        vm.assume(tokenAddress != address(0x0));
        _constrainFuzzInputs(
            testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee
        );
        _constrainFuzzInputs(
            overrideParams.baseFee, overrideParams.variableFee, overrideParams.ethBaseFee, overrideParams.ethVariableFee
        );

        deployWithFuzz(testParams.baseFee, testParams.variableFee, testParams.ethBaseFee, testParams.ethVariableFee);

        address someRecipient = address(0xdeadbeef);

        // set erc20 overrideFees
        FeeManager.Fees memory erc20OverrideFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, overrideParams.baseFee, overrideParams.variableFee);
        vm.prank(feeManager.owner());
        feeManager.setDefaultFees(tokenAddress, erc20OverrideFees);

        // calculate feeTotal using erc20 overrideFees
        uint256 erc20OverrideFeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedErc20OverrideFeeTotal = uint256(quantity) * uint256(overrideParams.baseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(overrideParams.variableFee) / 10_000);
        assertEq(erc20OverrideFeeTotal, expectedErc20OverrideFeeTotal);

        // set eth overrideFees
        FeeManager.Fees memory ethOverrideFees =
            FeeManager.Fees(FeeManager.FeeSetting.Set, overrideParams.ethBaseFee, overrideParams.ethVariableFee);
        vm.prank(feeManager.owner());
        feeManager.setDefaultFees(tokenAddress, ethOverrideFees);

        // calculate feeTotal using eth overrideFees
        uint256 ethOverrideFeeTotal =
            feeManager.getFeeTotals(address(proxy), tokenAddress, someRecipient, quantity, unitPrice);
        // cast to prevent overflow
        uint256 expectedEthOverrideFeeTotal = uint256(quantity) * uint256(overrideParams.ethBaseFee)
            + (uint256(unitPrice) * uint256(quantity) * uint256(overrideParams.ethVariableFee) / 10_000);
        assertEq(ethOverrideFeeTotal, expectedEthOverrideFeeTotal);
    }

    /*============
        HELPERS
    ============*/

    function deployWithFuzz(uint120 baseFee, uint120 variableFee, uint120 ethBaseFee, uint120 ethVariableFee) public {
        address owner = address(0xbeefbabe);
        // instantiate feeManager with fuzzed base and variable fees as baseline
        FeeManager.Fees memory exampleFees = FeeManager.Fees(FeeManager.FeeSetting.Set, baseFee, variableFee);
        FeeManager.Fees memory ethFees = FeeManager.Fees(FeeManager.FeeSetting.Set, ethBaseFee, ethVariableFee);

        feeManager = new FeeManager(owner, exampleFees, ethFees);
    }

    // function to constrain fuzzed test values to realistic values for performance
    // FeeManager.getFeeTotals() can overflow due to arithmetic in StablecoinPurchaseModule.mintPriceToStablecoinAmount()
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
