// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {FreeMintModule} from "src/v2/membership/modules/FreeMintModule.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract FreeMintModuleTest is Test, SetUpMembership {
    Membership public proxy;
    FreeMintModule public module;
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
    function initModule(uint120 baseFee, uint120 variableFee) public {
        // instantiate feeManager with fuzzed base and variable fees as baseline
        FeeManager.Fees memory exampleFees = FeeManager.Fees(FeeManager.FeeSetting.Free, baseFee, variableFee);
        feeManager = new FeeManager(owner, exampleFees, exampleFees);

        module = new FreeMintModule(owner, address(feeManager));

        // enable grants in module config setup and give module mint permission on proxy
        vm.startPrank(owner);
        module.setUp(address(proxy), false);
        proxy.permit(address(module), operationPermissions(Permissions.Operation.MINT));
        vm.stopPrank();
    }

    function test_mint(uint120 baseFee, uint120 variableFee) public {
        initModule(baseFee, variableFee);

        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, 1, 0);
        vm.deal(recipient, fee);

        vm.startPrank(recipient);
        // mint token
        uint256 tokenId = module.mint{value: fee}(address(proxy));

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
    }

    function test_mintRevertInvalidFee(uint120 baseFee, uint120 variableFee) public {
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

    function test_mintTo(uint120 baseFee, uint120 variableFee) public {
        initModule(baseFee, variableFee);

        address payer = createAccount();
        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, 1, 0);
        vm.deal(payer, fee);

        vm.startPrank(payer);
        // mint token
        uint256 tokenId = module.mintTo{value: fee}(address(proxy), recipient);

        // asserts
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
    }

    function test_mintToRevertInvalidFee(uint120 baseFee, uint120 variableFee) public {
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

    function test_batchMint(uint120 baseFee, uint120 variableFee, uint8 _quantity) public {
        // bounded fuzz inputs to a smaller range for performance, tests pass even for `uint64 _quantity`
        vm.assume(_quantity != 0);
        // bound cheatcode took too long so recasting works fine
        uint256 quantity = uint256(_quantity);
        initModule(baseFee, variableFee);

        address recipient = createAccount();

        uint256 fee = feeManager.getFeeTotals(address(proxy), address(0x0), recipient, quantity, 0);
        vm.deal(recipient, fee);
        uint256 initialBalance = recipient.balance;

        vm.startPrank(recipient);
        (uint256 startTokenId, uint256 endTokenId) = module.batchMint{value: fee}(address(proxy), quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < endTokenId - startTokenId; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), quantity);
        assertEq(recipient.balance, initialBalance - fee);
    }

    function test_batchMintRevertInvalidFee(uint120 baseFee, uint120 variableFee, uint8 _quantity) public {
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

    function test_batchMintTo(uint120 baseFee, uint120 variableFee, uint8 _quantity) public {
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

        vm.startPrank(payer);
        (uint256 startTokenId, uint256 endTokenId) = module.batchMintTo{value: fee}(address(proxy), recipient, quantity);

        // asserts
        assertEq(proxy.balanceOf(recipient), quantity);
        for (uint256 i; i < endTokenId - startTokenId; ++i) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), quantity);
        assertEq(recipient.balance, initialBalance - fee);
    }

    function test_batchMintToRevertInvalidFee(uint120 baseFee, uint120 variableFee, uint8 _quantity) public {
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
