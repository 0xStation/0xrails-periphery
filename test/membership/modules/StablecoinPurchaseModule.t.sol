// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {IERC721Internal} from "0xrails/cores/ERC721/interface/IERC721.sol";
import {IPermissionsInternal as IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {IGuardsInternal as IGuards} from "0xrails/guard/interface/IGuards.sol";

// src

import {SetupController} from "src/lib/module/SetupController.sol";
import {StablecoinPurchaseController} from "src/membership/modules/StablecoinPurchaseController.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
// test
import {SetUpMembership} from "test/lib/SetUpMembership.sol";
import {FakeERC20} from "test/utils/FakeERC20.sol";

contract StablecoinPurchaseControllerTest is Test, SetUpMembership {
    // struct populated with test params to solve `stack too deep` errors for funcs with > 16 variables
    struct TestParams {
        uint8 coinDecimals;
        uint8 moduleDecimals;
        uint120 baseFee;
        uint120 variableFee;
        uint128 price;
    }

    ERC721Rails public proxy;
    StablecoinPurchaseController public stablecoinModule;
    FakeERC20 public stablecoin;
    FeeManager public feeManager;

    // intended to contain custom error signatures
    bytes public err;

    // transplanted from FeeControllerV2 since custom errors are not externally visible
    error InvalidFee(uint256 expected, uint256 received);

    function setUp() public override {
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        proxy = SetUpMembership.create();
    }

    /*============
        CONFIG
    ============*/

    function test_register(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price
    ) public {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        // initial null states sanity asserts
        assertEq(stablecoinModule.keyCounter(), 0);
        err = bytes("STABLECOIN_NOT_REGISTERED");
        vm.expectRevert(err);
        stablecoinModule.keyOf(address(stablecoin));
        err = bytes("KEY_NOT_REGISTERED");
        vm.expectRevert(err);
        stablecoinModule.stablecoinOf(1);

        // register
        vm.prank(owner);
        stablecoinModule.register(address(stablecoin));
        // check key added
        assertEq(stablecoinModule.keyOf(address(stablecoin)), 1);
        // check stablecoin added
        assertEq(stablecoinModule.stablecoinOf(1), address(stablecoin));
        // check key counter incremented
        assertEq(stablecoinModule.keyCounter(), 1);
        // check stablecoins list
        address[] memory registeredStablecoins = new address[](1);
        registeredStablecoins[0] = address(stablecoin);
        assertEq(stablecoinModule.stablecoinOptions(), registeredStablecoins);
    }

    function test_registerRevertNotOwner(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        address caller
    ) public {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        vm.assume(caller != owner);
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        stablecoinModule.register(address(stablecoin));
        // check stablecoin NOT registered
        vm.expectRevert("STABLECOIN_NOT_REGISTERED");
        stablecoinModule.keyOf(address(stablecoin));
        // check key NOT registered
        uint8 lastKey = stablecoinModule.keyCounter();
        vm.expectRevert("KEY_NOT_REGISTERED");
        stablecoinModule.stablecoinOf(lastKey);
    }

    function test_registerRevertAlreadyRegistered(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price
    ) public {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        vm.startPrank(owner);
        stablecoinModule.register(address(stablecoin));
        vm.expectRevert("STABLECOIN_ALREADY_REGISTERED");
        stablecoinModule.register(address(stablecoin));
    }

    function test_registerMultiple(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        address randomAddress
    ) public {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        vm.startPrank(owner);
        // register stablecoin
        stablecoinModule.register(address(stablecoin));
        // check key 1 added
        assertEq(stablecoinModule.keyOf(address(stablecoin)), 1);
        assertEq(stablecoinModule.stablecoinOf(1), address(stablecoin));
        assertEq(stablecoinModule.keyCounter(), 1);
        // register randomAddress
        stablecoinModule.register(randomAddress);
        // check key 2 added
        assertEq(stablecoinModule.keyOf(randomAddress), 2);
        assertEq(stablecoinModule.stablecoinOf(2), randomAddress);
        assertEq(stablecoinModule.keyCounter(), 2);
    }

    /*============
        SET UP
    ============*/

    function test_setUp(uint8 coinDecimals, uint8 moduleDecimals, uint120 baseFee, uint120 variableFee, uint128 price)
        public
    {
        initRegister(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        vm.prank(owner);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);

        // check stablecoin enabled
        assertEq(stablecoinModule.stablecoinEnabled(address(proxy), address(stablecoin)), true);
        // check all enabled coins
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), stablecoins);
        // check price set
        assertEq(stablecoinModule.priceOf(address(proxy)), price);
    }

    function test_setUpAsAdmin(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        address admin
    ) public {
        vm.assume(admin != owner);

        initRegister(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        // set up ADMIN permission
        vm.prank(owner);
        proxy.addPermission(Operations.ADMIN, admin);

        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);

        // setUp() as non-owner admin
        vm.prank(admin);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);

        // check stablecoin enabled
        assertEq(stablecoinModule.stablecoinEnabled(address(proxy), address(stablecoin)), true);
        // check all enabled coins
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), stablecoins);
        // check price set
        assertEq(stablecoinModule.priceOf(address(proxy)), price);
    }

    function test_setUpRevertNotPermitted(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        address randomAddress
    ) public {
        vm.assume(randomAddress != owner);

        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        // following code is identical to initModuleAndErc20() but w/out calling module.setUp(proxy) and proxy.permit
        // instantiate feeManager with fuzzed base and variable fees as baseline
        vm.assume(baseFee != 0); // since this test file tests stablecoins, FeeSetting.Set is used and baseFee should != 0
        feeManager = new FeeManager(owner, baseFee, variableFee, baseFee, variableFee);

        stablecoin = new FakeERC20(coinDecimals);
        address[] memory stablecoins = new address[](0);

        stablecoinModule = new StablecoinPurchaseController(
            owner, 
            address(feeManager), 
            moduleDecimals,
            "USD",
            stablecoins,
            address(metadataRouter)
        );

        address[] memory setupStablecoins = new address[](1);
        setupStablecoins[0] = address(stablecoin);
        // prank as not-permitted, non-owner randomAddress
        vm.prank(randomAddress);
        err = abi.encodeWithSelector(SetupController.SetUpUnauthorized.selector, address(proxy), randomAddress);
        vm.expectRevert(err);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);

        // check stablecoin NOT enabled
        err = bytes("STABLECOIN_NOT_REGISTERED");
        vm.expectRevert(err);
        stablecoinModule.stablecoinEnabled(address(proxy), address(stablecoin));
        // check all enabled coins
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), new address[](0));
        // check price NOT set
        vm.expectRevert("NO_PRICE");
        stablecoinModule.priceOf(address(proxy));
    }

    function test_setUpRevertZeroPrice(uint8 coinDecimals, uint8 moduleDecimals, uint120 baseFee, uint120 variableFee)
        public
    {
        vm.assume(baseFee != 0); // since this test file tests stablecoins, FeeSetting.Set is used and baseFee should != 0
        // following code is identical to initModuleAndErc20() but w/out calling module.setUp(proxy) and proxy.permit
        // instantiate feeManager with fuzzed base and variable fees as baseline
        feeManager = new FeeManager(owner, baseFee, variableFee, baseFee, variableFee);

        stablecoin = new FakeERC20(coinDecimals);
        address[] memory stablecoins = new address[](0);

        stablecoinModule = new StablecoinPurchaseController(
            owner, 
            address(feeManager), 
            moduleDecimals,
            "USD",
            stablecoins,
            address(metadataRouter)
        );

        address[] memory setupStablecoins = new address[](1);
        setupStablecoins[0] = address(stablecoin);
        vm.prank(owner);
        // attempt set zero price
        uint128 zeroPrice = 0;
        vm.expectRevert("ZERO_PRICE");
        stablecoinModule.setUp(address(proxy), zeroPrice, stablecoins, false);

        // check stablecoin NOT enabled
        vm.expectRevert("STABLECOIN_NOT_REGISTERED");
        stablecoinModule.stablecoinEnabled(address(proxy), address(stablecoin));
        // check all enabled coins
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), new address[](0));
        // check price NOT set
        vm.expectRevert("NO_PRICE");
        stablecoinModule.priceOf(address(proxy));
    }

    function test_setUpUnsupportedStablecoin(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price
    ) public {
        // calls setUp() on the proxy address with price but doesn't provide stablecoin addrs
        initRegister(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        assertEq(stablecoinModule.priceOf(address(proxy)), price);
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), new address[](0));

        // call setUp() to add new supported stablecoin to proxy collection
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        vm.prank(owner);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);
        // check proxy collection and first stablecoin were registered
        assertEq(stablecoinModule.priceOf(address(proxy)), price);
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), stablecoins);

        // create stablecoin array of address that has not been registered to stablecoinModule
        address unsupportedStablecoin = address(0xbeefEbabe);
        address[] memory unsupportedStables = new address[](1);
        unsupportedStables[0] = unsupportedStablecoin;

        vm.prank(owner);
        vm.expectRevert("STABLECOIN_NOT_REGISTERED");
        stablecoinModule.setUp(address(proxy), price, unsupportedStables, false);
        // check there is still only one enabled coin
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), stablecoins);
    }

    function test_setUpFromProxy(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price
    ) public {
        // initRegister(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        vm.assume(baseFee != 0); // since this test file tests stablecoins, FeeSetting.Set is used and baseFee should != 0
        // instantiate feeManager with fuzzed base and variable fees as baseline
        feeManager = new FeeManager(owner, baseFee, variableFee, baseFee, variableFee);

        // deploy fake stablecoin but not include it in stablecoinModule constructor
        stablecoin = new FakeERC20(coinDecimals);

        // pass empty initial stables array to stablecoinModule constructor
        stablecoinModule = new StablecoinPurchaseController(
            owner, 
            address(feeManager), 
            moduleDecimals,
            "USD",
            new address[](0),
            address(metadataRouter)
        );

        vm.prank(owner);
        stablecoinModule.register(address(stablecoin));

        // prepare setUp call to be made through proxy
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes memory setUpModuleData =
            abi.encodeWithSignature("setUp(uint128,address[],bool)", price, stablecoins, false);
        bytes memory executeModuleSetUpData =
            abi.encodeWithSelector(proxy.executeCall.selector, address(stablecoinModule), 0, setUpModuleData);
        bytes memory addPermissionData =
            abi.encodeWithSelector(proxy.addPermission.selector, Operations.MINT, address(stablecoinModule));

        bytes[] memory calls = new bytes[](2);
        calls[0] = addPermissionData;
        calls[1] = executeModuleSetUpData;

        vm.prank(owner);
        proxy.multicall(calls);

        // check stablecoin enabled
        assertEq(stablecoinModule.stablecoinEnabled(address(proxy), address(stablecoin)), true);
        // check all enabled coins
        assertEq(stablecoinModule.enabledCoinsOf(address(proxy)), stablecoins);
        // check price set
        assertEq(stablecoinModule.priceOf(address(proxy)), price);
    }

    /*====================
        PURCHASE PRICE
    ====================*/

    // mintPriceToStablecoinAmount() can overflow if `price` exceeds type(120).max: (1.3e36)
    function test_mintPriceToStablecoinAmount(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price
    ) public {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        if (coinDecimals == moduleDecimals) {
            assertEq(stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), price);
        } else if (coinDecimals > moduleDecimals) {
            assertEq(
                stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)),
                price * 10 ** (coinDecimals - moduleDecimals)
            );
        } else {
            uint256 precisionLoss = 10 ** (moduleDecimals - coinDecimals);
            uint256 trimmedPrice = price / precisionLoss;
            uint256 remainder = price - trimmedPrice * precisionLoss; // intentionally different from r = a % n
            if (remainder > 0) {
                assertEq(stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), trimmedPrice + 1);
            } else {
                assertEq(stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), trimmedPrice);
            }
        }
    }

    function test_mintPriceToStablecoinAmountUSDC(uint120 baseFee, uint120 variableFee, uint128 price) public {
        vm.assume(price != 0);

        uint8 coinDecimals = 6;
        uint8 moduleDecimals = 4;

        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        assertEq(stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) * 100);
    }

    function test_mintPriceToStablecoinAmountDAI(uint120 baseFee, uint120 variableFee, uint128 price) public {
        vm.assume(price != 0);

        uint8 coinDecimals = 18;
        uint8 moduleDecimals = 4;

        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        assertEq(stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) * 10 ** 14);
    }

    function test_mintPriceToStablecoinAmountWBTC(uint120 baseFee, uint120 variableFee, uint128 price) public {
        vm.assume(price != 0);

        uint8 coinDecimals = 18;
        uint8 moduleDecimals = 18;

        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        assertEq(stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price));
    }

    function test_mintPriceToStablecoinAmountInverse(uint120 baseFee, uint120 variableFee, uint128 price) public {
        // bound fuzzed price value to less than ie
        vm.assume(price != 0 && price < type(uint128).max / 10e9);

        uint8 coinDecimals = 4;
        uint8 moduleDecimals = 18;

        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        // arithmetic in this check can cause overflow for values of price > ~1e32
        if (price % 10 ** 14 > 0) {
            assertEq(
                stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) / 10 ** 14 + 1
            );
        } else {
            assertEq(
                stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) / 10 ** 14
            );
        }
    }

    /*==========
        MINT
    ==========*/

    function test_mint(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (address buyer,, uint256 buyerInitialStablecoinBalance, uint256 payoutAddressInitialStablecoinBalance) =
            initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        uint256 amount = 1; // single mint
        uint256 priceFormattedDecimals = stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin));
        uint256 stablecoinFee =
            feeManager.getFeeTotals(address(proxy), address(stablecoin), buyer, amount, priceFormattedDecimals);

        vm.prank(buyer);
        // mint token
        stablecoinModule.mint(address(proxy), address(stablecoin));
        uint256 tokenId = proxy.totalSupply();
        // **buyer** received token
        assertEq(proxy.balanceOf(buyer), 1);
        assertEq(proxy.ownerOf(tokenId), buyer);
        assertEq(proxy.totalSupply(), 1);

        // buyer stablecoin balance decreased by totalInclFees
        uint256 purchaseAmount = amount * priceFormattedDecimals;
        uint256 totalInclFees = purchaseAmount + stablecoinFee;
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - totalInclFees);
        // payoutAddress stablecoin balance increased by purchaseAmount
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance + purchaseAmount);
    }

    function test_mintTo(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (address buyer,, uint256 buyerInitialStablecoinBalance, uint256 payoutAddressInitialStablecoinBalance) =
            initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // recipient is NOT buyer
        address recipient = createAccount();

        uint256 amount = 1; // single mint
        uint256 priceFormattedDecimals = stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin));
        uint256 stablecoinFee =
            feeManager.getFeeTotals(address(proxy), address(stablecoin), buyer, amount, priceFormattedDecimals);

        vm.prank(buyer);
        // mint token
        stablecoinModule.mintTo(address(proxy), address(stablecoin), recipient);
        uint256 tokenId = proxy.totalSupply();
        // **recipient** received token
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);

        // buyer stablecoin balance decreased by totalInclFees
        uint256 totalInclFees = priceFormattedDecimals + stablecoinFee;
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - totalInclFees);
        // payoutAddress stablecoin balance increased by purchase amount
        assertEq(
            stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance + priceFormattedDecimals * amount
        );
    }

    function test_mintRevertStablecoinNotEnabled(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        address[] memory stablecoins = new address[](0);

        // disable all tokens
        vm.prank(owner);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);

        vm.prank(buyer);
        vm.expectRevert("STABLECOIN_NOT_ENABLED");
        stablecoinModule.mint(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintRevertInvalidFee(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (address buyer, uint256 buyerInitialBalance,, uint256 payoutAddressInitialStablecoinBalance) =
            initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // burn all but 1 unit of stablecoin to ensure payment is invalid
        uint256 stableBalance = stablecoin.balanceOf(buyer);
        vm.prank(buyer);
        stablecoin.transfer(address(0xdead), stableBalance);

        uint256 amount = 1; // single mint

        uint256 priceFormattedDecimals = stablecoinModule.mintPriceToStablecoinAmount(price, address(stablecoin));
        feeManager.getFeeTotals(address(proxy), address(stablecoin), buyer, amount, priceFormattedDecimals);

        // attempt mint with invalid fee ie insufficient stablecoin balance
        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        vm.prank(buyer);
        stablecoinModule.mint(address(proxy), address(stablecoin));

        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);

        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);

        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintRevertMissingPayoutAddress(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // remove payout address
        vm.prank(owner);
        IPayoutAddress(address(proxy)).removePayoutAddress();

        vm.prank(buyer);
        vm.expectRevert("MISSING_PAYOUT_ADDRESS");
        stablecoinModule.mint(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintRevertInsufficientAllowance(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // wipe stablecoin's approval for module
        vm.prank(buyer);
        stablecoin.approve(address(stablecoinModule), 0);

        vm.prank(buyer);
        vm.expectRevert("ERC20: insufficient allowance");
        stablecoinModule.mint(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintRevertInsufficientAllowanceSafeERC20(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // change to variant with no reverts
        stablecoin.toggleRevert();

        // wipe stablecoin's approval for module
        vm.prank(buyer);
        stablecoin.approve(address(stablecoinModule), 0);

        vm.prank(buyer);
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        stablecoinModule.mint(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintToRevertInvalidReceiver(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        vm.prank(buyer);
        vm.expectRevert(IERC721Internal.TransferToNonERC721ReceiverImplementer.selector);
        stablecoinModule.mintTo(address(proxy), address(stablecoin), address(stablecoinModule));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintToRevertInvalidReceiverSafeERC20(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);
        // change to variant with no reverts to emulate differing stablecoin transfer impls
        stablecoin.toggleRevert();

        vm.prank(buyer);
        vm.expectRevert(IERC721Internal.TransferToNonERC721ReceiverImplementer.selector);
        stablecoinModule.mintTo(address(proxy), address(stablecoin), address(stablecoinModule));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintRevertGuardRejection(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // set guard to reject all mints
        vm.prank(owner);
        proxy.setGuard(Operations.MINT, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(
                IGuards.GuardRejected.selector, Operations.MINT, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF
            )
        );
        stablecoinModule.mint(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintRevertDisabledModule(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        // disable module
        vm.prank(owner);
        proxy.removePermission(Operations.MINT, address(stablecoinModule));

        vm.prank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(
                IPermissions.PermissionDoesNotExist.selector, Operations.MINT, address(stablecoinModule)
            )
        );
        stablecoinModule.mint(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    function test_mintToRevertRecipientZeroAddress(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        vm.prank(buyer);
        vm.expectRevert(IERC721Internal.MintToZeroAddress.selector);
        stablecoinModule.mintTo(address(proxy), address(stablecoin), address(0));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    /*==============
        BATCHMINT
    ==============*/

    function test_batchMint(TestParams calldata testParams, uint64 balanceOffset, uint8 amount) public {
        vm.assume(amount > 0);
        (address buyer,, uint256 buyerInitialStablecoinBalance, uint256 payoutAddressInitialStablecoinBalance) =
        initModuleAndBuyer(
            testParams.coinDecimals,
            testParams.moduleDecimals,
            testParams.baseFee,
            testParams.variableFee,
            testParams.price,
            balanceOffset,
            amount
        );

        uint256 initialTotalSupply = proxy.totalSupply();
        uint256 startTokenId = initialTotalSupply + 1;

        // mint token
        vm.prank(buyer);
        stablecoinModule.batchMint(address(proxy), address(stablecoin), amount);
        // **buyer** received token
        assertEq(proxy.balanceOf(buyer), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(proxy.ownerOf(startTokenId + i), buyer);
        }
        assertEq(proxy.totalSupply(), initialTotalSupply + amount);

        uint256 priceFormattedDecimals =
            stablecoinModule.mintPriceToStablecoinAmount(testParams.price, address(stablecoin));
        uint256 stablecoinFee =
            feeManager.getFeeTotals(address(proxy), address(stablecoin), buyer, amount, priceFormattedDecimals);
        uint256 purchaseAmount = amount * priceFormattedDecimals;
        uint256 totalInclFees = purchaseAmount + stablecoinFee;

        // buyer stablecoin balance decreased by totalInclFees
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - totalInclFees);
        // payoutAddress stablecoin balance increased by purchaseAmount
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance + purchaseAmount);
    }

    function test_batchMintTo(TestParams calldata testParams, uint64 balanceOffset, uint8 amount) public {
        vm.assume(amount > 0);
        (address buyer,, uint256 buyerInitialStablecoinBalance, uint256 payoutAddressInitialStablecoinBalance) =
        initModuleAndBuyer(
            testParams.coinDecimals,
            testParams.moduleDecimals,
            testParams.baseFee,
            testParams.variableFee,
            testParams.price,
            balanceOffset,
            amount
        );

        // recipient is NOT buyer
        address recipient = createAccount();

        uint256 initialTotalSupply = proxy.totalSupply();
        uint256 startTokenId = initialTotalSupply + 1;

        // mint token
        vm.prank(buyer);
        stablecoinModule.batchMintTo(address(proxy), address(stablecoin), recipient, amount);
        // **recipient** received token
        assertEq(proxy.balanceOf(recipient), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(proxy.ownerOf(startTokenId + i), recipient);
        }
        assertEq(proxy.totalSupply(), initialTotalSupply + amount);

        uint256 priceFormattedDecimals =
            stablecoinModule.mintPriceToStablecoinAmount(testParams.price, address(stablecoin));
        uint256 stablecoinFee =
            feeManager.getFeeTotals(address(proxy), address(stablecoin), recipient, amount, priceFormattedDecimals);
        uint256 purchaseAmount = amount * priceFormattedDecimals;
        uint256 totalInclFees = purchaseAmount + stablecoinFee;

        // buyer stablecoin balance decreased by totalInclFees
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - totalInclFees);
        // payoutAddress stablecoin balance increased by purchaseAmount
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance + purchaseAmount);
    }

    function test_batchMintRevertZeroAmount(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    ) public {
        // no tokens
        uint8 amount = 0;

        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset);

        vm.prank(buyer);
        // mint token
        vm.expectRevert("ZERO_AMOUNT");
        stablecoinModule.batchMint(address(proxy), address(stablecoin), amount);

        // buyer does NOT received token
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // payoutAddress stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(payoutAddress), payoutAddressInitialStablecoinBalance);
    }

    /*============
        HELPERS
    ============*/

    /// @notice Helper functions are not invoked as standalone tests

    // function to constrain fuzzed test values to realistic values for performance
    // FeeManager.getFeeTotals() can overflow due to arithmetic in StablecoinPurchaseController.mintPriceToStablecoinAmount()
    // but only on impossibly high fees, price, & decimals causing a revert, roughly:
    // if (1e_coinDecimals * 1e_moduleDecimals * _baseFee * _variableFee * _price > type(uint256).max)
    function _constrainFuzzInputs(
        uint8 _coinDecimals,
        uint8 _moduleDecimals,
        uint120 _baseFee,
        uint120 _variableFee,
        uint128 _price
    ) internal pure {
        // limit coin and module decimals to roughly match that of _price: type(uint96).max
        uint256 decimalLimit = 30;
        vm.assume(_coinDecimals < decimalLimit);
        vm.assume(_moduleDecimals < decimalLimit);

        // disallow extreme price && fee values to prevent decimal handling from overflowing
        vm.assume(_price > 0 && _price < type(uint96).max);
        vm.assume(_baseFee < type(uint64).max);
        vm.assume(_variableFee < type(uint64).max);
    }

    // helper function to initialize module, ERC20, and register the ERC20 with the module for each test function
    function initRegister(uint8 coinDecimals, uint8 moduleDecimals, uint120 baseFee, uint120 variableFee, uint128 price)
        public
    {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initModuleAndErc20(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        vm.prank(owner);
        stablecoinModule.register(address(stablecoin));
    }

    // helper function to initialize module and ERC20 (but not register it) for each test function
    function initModuleAndErc20(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price
    ) public {
        vm.assume(baseFee != 0); // since this test file tests stablecoins, FeeSetting.Set is used and baseFee should != 0
        // instantiate feeManager with fuzzed base and variable fees as baseline
        feeManager = new FeeManager(owner, baseFee, variableFee, baseFee, variableFee);

        // deploy fake stablecoin but not include it in stablecoinModule constructor
        stablecoin = new FakeERC20(coinDecimals);

        // pass empty initial stables array to stablecoinModule constructor
        address[] memory stablecoins = new address[](0);
        stablecoinModule = new StablecoinPurchaseController(
            owner, 
            address(feeManager), 
            moduleDecimals,
            "USD",
            stablecoins,
            address(metadataRouter)
        );

        // enable grants in module config setup and give module mint permission on proxy
        vm.startPrank(owner);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);
        proxy.addPermission(Operations.MINT, address(stablecoinModule));
        vm.stopPrank();
    }

    // helper function to init module, init + register ERC20, set paymentCollector, create buyer addr & fund it w/ both ETH + ERC20s
    function initModuleAndBuyer(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset,
        uint8 amount
    )
        public
        returns (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 payoutAddressInitialStablecoinBalance
        )
    {
        _constrainFuzzInputs(coinDecimals, moduleDecimals, baseFee, variableFee, price);
        initRegister(coinDecimals, moduleDecimals, baseFee, variableFee, price);

        // add stablecoin to module
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);

        vm.startPrank(owner);
        stablecoinModule.setUp(address(proxy), price, stablecoins, false);
        // set payment collector
        IPayoutAddress(address(proxy)).updatePayoutAddress(payoutAddress);

        vm.stopPrank();

        // init buyer
        buyer = createAccount();

        // deal stablecoin for purchase
        uint256 priceFormattedDecimals =
            stablecoinModule.mintPriceToStablecoinAmount(uint256(price), address(stablecoin));
        uint256 stablecoinFee =
            feeManager.getFeeTotals(address(proxy), address(stablecoin), buyer, amount, priceFormattedDecimals);
        uint256 purchaseAmount = amount * priceFormattedDecimals;
        buyerInitialStablecoinBalance = stablecoinFee + purchaseAmount + uint256(balanceOffset); // cast to prevent overflow
        stablecoin.mint(buyer, buyerInitialStablecoinBalance);
        // allow module to spend buyer's stablecoin
        vm.prank(buyer);
        stablecoin.increaseAllowance(address(stablecoinModule), buyerInitialStablecoinBalance);

        payoutAddressInitialStablecoinBalance = stablecoin.balanceOf(payoutAddress);

        return (buyer, buyerInitialBalance, buyerInitialStablecoinBalance, payoutAddressInitialStablecoinBalance);
    }

    function initModuleAndBuyer(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint120 baseFee,
        uint120 variableFee,
        uint128 price,
        uint64 balanceOffset
    )
        public
        returns (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        )
    {
        return initModuleAndBuyer(coinDecimals, moduleDecimals, baseFee, variableFee, price, balanceOffset, 1);
    }
}
