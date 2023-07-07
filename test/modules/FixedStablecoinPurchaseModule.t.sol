// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// src
import {Test} from "forge-std/Test.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {StablecoinPurchaseModule} from "src/membership/modules/StablecoinPurchaseModule.sol";
// test
import {SetUpMembership} from "test/lib/SetUpMembership.sol";
import {FakeERC20} from "test/utils/FakeERC20.sol";

contract StablecoinPurchaseModuleTest is Test, SetUpMembership {
    Membership public proxy;
    StablecoinPurchaseModule public module;
    FakeERC20 public stablecoin;

    function setUp() public override {
        SetUpMembership.setUp(); // paymentCollector, renderer, implementation, factory
        proxy = SetUpMembership.create();
    }

    /*============
        CONFIG
    ============*/

    function initDeploys(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee) public {
        vm.assume(coinDecimals < 50 && moduleDecimals < 50);
        module = new StablecoinPurchaseModule(owner, fee, moduleDecimals, "TEST");
        stablecoin = new FakeERC20(coinDecimals);
    }

    function test_register(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee) public {
        initDeploys(coinDecimals, moduleDecimals, fee);

        vm.prank(owner);
        module.register(address(stablecoin));
        // check key added
        assertEq(module.keyOf(address(stablecoin)), 1);
        // check stablecoin added
        assertEq(module.stablecoinOf(1), address(stablecoin));
        // check key counter incremented
        assertEq(module.keyCounter(), 1);
    }

    function test_register_revert_notOwner(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, address caller)
        public
    {
        initDeploys(coinDecimals, moduleDecimals, fee);

        vm.assume(caller != owner);
        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        module.register(address(stablecoin));
        // check stablecoin NOT registered
        vm.expectRevert("STABLECOIN_NOT_REGISTERED");
        module.keyOf(address(stablecoin));
        // check key NOT registered
        uint8 lastKey = module.keyCounter();
        vm.expectRevert("KEY_NOT_REGISTERED");
        module.stablecoinOf(lastKey);
    }

    function test_register_revert_alreadyRegistered(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee) public {
        initDeploys(coinDecimals, moduleDecimals, fee);

        vm.startPrank(owner);
        module.register(address(stablecoin));
        vm.expectRevert("STABLECOIN_ALREADY_REGISTERED");
        module.register(address(stablecoin));
    }

    function test_register_multiple(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, address randomAddress)
        public
    {
        initDeploys(coinDecimals, moduleDecimals, fee);

        vm.startPrank(owner);
        // register stablecoin
        module.register(address(stablecoin));
        // check key 1 added
        assertEq(module.keyOf(address(stablecoin)), 1);
        assertEq(module.stablecoinOf(1), address(stablecoin));
        assertEq(module.keyCounter(), 1);
        // register randomAddress
        module.register(randomAddress);
        // check key 2 added
        assertEq(module.keyOf(randomAddress), 2);
        assertEq(module.stablecoinOf(2), randomAddress);
        assertEq(module.keyCounter(), 2);
    }

    /*============
        SET UP
    ============*/

    function initRegister(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee) public {
        initDeploys(coinDecimals, moduleDecimals, fee);

        vm.prank(owner);
        module.register(address(stablecoin));
    }

    function test_setUp(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, uint128 price) public {
        initRegister(coinDecimals, moduleDecimals, fee);

        vm.assume(price > 0);
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes16 enabledCoins = module.enabledCoinsValue(stablecoins);
        vm.prank(owner);
        module.setUp(address(proxy), price, enabledCoins);

        // check stablecoin enabled
        assertEq(module.stablecoinEnabled(address(proxy), address(stablecoin)), true);
        // check all enables coins
        assertEq(module.enabledCoinsOf(address(proxy)), stablecoins);
        // check all enables coins value
        assertEq(module.enabledCoinsValueOf(address(proxy)), bytes16(uint128(2)));
        // check price set
        assertEq(module.priceOf(address(proxy)), price);
    }

    function test_setUp_notOwner(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, uint128 price, address admin)
        public
    {
        initRegister(coinDecimals, moduleDecimals, fee);

        // set up UPGRADE permission
        vm.assume(admin != owner);
        vm.prank(owner);
        proxy.permit(admin, operationPermissions(Permissions.Operation.UPGRADE));

        vm.assume(price > 0);
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes16 enabledCoins = module.enabledCoinsValue(stablecoins);
        // prank as non-owner admin
        vm.prank(admin);
        module.setUp(address(proxy), price, enabledCoins);

        // check stablecoin enabled
        assertEq(module.stablecoinEnabled(address(proxy), address(stablecoin)), true);
        // check all enables coins
        assertEq(module.enabledCoinsOf(address(proxy)), stablecoins);
        // check all enables coins value
        assertEq(module.enabledCoinsValueOf(address(proxy)), bytes16(uint128(2)));
        // check price set
        assertEq(module.priceOf(address(proxy)), price);
    }

    function test_setUp_revert_notPermitted(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint128 price,
        address randomAddress
    ) public {
        initRegister(coinDecimals, moduleDecimals, fee);

        vm.assume(randomAddress != owner);

        vm.assume(price > 0);
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes16 enabledCoins = module.enabledCoinsValue(stablecoins);
        // prank as not-permitted, non-owner randomAddress
        vm.prank(randomAddress);
        vm.expectRevert("NOT_PERMITTED");
        module.setUp(address(proxy), price, enabledCoins);

        // check stablecoin NOT enabled
        assertEq(module.stablecoinEnabled(address(proxy), address(stablecoin)), false);
        // check all enables coins
        assertEq(module.enabledCoinsOf(address(proxy)), new address[](0));
        // check all enables coins value
        assertEq(module.enabledCoinsValueOf(address(proxy)), bytes16(uint128(0)));
        // check price NOT set
        vm.expectRevert("NO_PRICE");
        module.priceOf(address(proxy));
    }

    function test_setUp_revert_zeroPrice(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee) public {
        initRegister(coinDecimals, moduleDecimals, fee);

        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes16 enabledCoins = module.enabledCoinsValue(stablecoins);
        vm.prank(owner);
        // attempt set zero price
        uint64 price = 0;
        vm.expectRevert("ZERO_PRICE");
        module.setUp(address(proxy), price, enabledCoins);

        // check stablecoin NOT enabled
        assertEq(module.stablecoinEnabled(address(proxy), address(stablecoin)), false);
        // check all enables coins
        assertEq(module.enabledCoinsOf(address(proxy)), new address[](0));
        // check all enables coins value
        assertEq(module.enabledCoinsValueOf(address(proxy)), bytes16(uint128(0)));
        // check price NOT set
        vm.expectRevert("NO_PRICE");
        module.priceOf(address(proxy));
    }

    function test_setUp_fromProxy(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, uint128 price) public {
        initRegister(coinDecimals, moduleDecimals, fee);

        vm.assume(price > 0);
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes16 enabledCoins = module.enabledCoinsValue(stablecoins);
        // module.setUp(address(proxy), price, enabledCoins);
        bytes4 selector = bytes4(keccak256("setUp(uint128,bytes16)"));
        bytes memory setupData = abi.encodeWithSelector(selector, price, enabledCoins);

        vm.prank(owner);
        proxy.permitAndSetup(address(module), operationPermissions(Permissions.Operation.MINT), setupData);

        // check stablecoin enabled
        assertEq(module.stablecoinEnabled(address(proxy), address(stablecoin)), true);
        // check all enables coins
        assertEq(module.enabledCoinsOf(address(proxy)), stablecoins);
        // check all enables coins value
        assertEq(module.enabledCoinsValueOf(address(proxy)), bytes16(uint128(2)));
        // check price set
        assertEq(module.priceOf(address(proxy)), price);
    }

    /*===================
        ENABLED COINS
    ===================*/

    function test_enabledCoinsValue(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee) public {
        initRegister(coinDecimals, moduleDecimals, fee);

        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        // check enabledCoinsValue
        assertEq(module.enabledCoinsValue(stablecoins), bytes16(uint128(2 ** module.keyOf(address(stablecoin)))));
    }

    function test_enabledCoinsValue_multiple(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        address randomAddress
    ) public {
        initRegister(coinDecimals, moduleDecimals, fee);

        // register second randomAddress
        vm.prank(owner);
        module.register(randomAddress);

        address[] memory stablecoins = new address[](2);
        stablecoins[0] = address(stablecoin);
        stablecoins[1] = randomAddress;
        // check enabledCoinsValue
        assertEq(
            module.enabledCoinsValue(stablecoins),
            bytes16(uint128(2 ** module.keyOf(address(stablecoin)) + 2 ** module.keyOf(randomAddress)))
        );
    }

    /*====================
        PURCHASE PRICE
    ====================*/

    function test_mintPriceToStablecoinAmount(uint8 coinDecimals, uint8 moduleDecimals, uint64 price) public {
        initDeploys(coinDecimals, moduleDecimals, 1);

        if (coinDecimals == moduleDecimals) {
            assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), price);
        } else if (coinDecimals > moduleDecimals) {
            assertEq(
                module.mintPriceToStablecoinAmount(price, address(stablecoin)),
                price * 10 ** (coinDecimals - moduleDecimals)
            );
        } else {
            uint256 precisionLoss = 10 ** (moduleDecimals - coinDecimals);
            uint256 trimmedPrice = price / precisionLoss;
            uint256 remainder = price - trimmedPrice * precisionLoss; // intentionally different from r = a % n
            if (remainder > 0) {
                assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), trimmedPrice + 1);
            } else {
                assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), trimmedPrice);
            }
        }
    }

    function test_mintPriceToStablecoinAmount_USDC(uint64 price) public {
        uint8 coinDecimals = 6;
        uint8 moduleDecimals = 4;
        initDeploys(coinDecimals, moduleDecimals, 1);

        assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) * 100);
    }

    function test_mintPriceToStablecoinAmount_DAI(uint64 price) public {
        uint8 coinDecimals = 18;
        uint8 moduleDecimals = 4;
        initDeploys(coinDecimals, moduleDecimals, 1);

        assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) * 10 ** 14);
    }

    function test_mintPriceToStablecoinAmount_WBTC(uint64 price) public {
        uint8 coinDecimals = 18;
        uint8 moduleDecimals = 18;
        initDeploys(coinDecimals, moduleDecimals, 1);

        assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price));
    }

    function test_mintPriceToStablecoinAmount_inverse(uint64 price) public {
        uint8 coinDecimals = 4;
        uint8 moduleDecimals = 18;
        initDeploys(coinDecimals, moduleDecimals, 1);

        if (price % 10 ** 14 > 0) {
            assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) / 10 ** 14 + 1);
        } else {
            assertEq(module.mintPriceToStablecoinAmount(price, address(stablecoin)), uint256(price) / 10 ** 14);
        }
    }

    /*==========
        MINT
    ==========*/

    function initModuleAndBuyer(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint128 price,
        uint64 balanceOffset,
        uint8 amount
    )
        public
        returns (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        )
    {
        initRegister(coinDecimals, moduleDecimals, fee);

        // init module
        vm.assume(price > 0);
        address[] memory stablecoins = new address[](1);
        stablecoins[0] = address(stablecoin);
        bytes16 enabledCoins = module.enabledCoinsValue(stablecoins);
        vm.startPrank(owner);
        module.setUp(address(proxy), price, enabledCoins);
        // give module mint permission on proxy
        proxy.permit(address(module), operationPermissions(Permissions.Operation.MINT));
        // set payment collector
        proxy.updatePaymentCollector(owner);
        vm.stopPrank();

        // init buyer
        buyer = createAccount();
        // deal ETH for fee
        buyerInitialBalance = uint256(fee) * uint256(amount) + uint256(balanceOffset); // cast to prevent overflow
        vm.deal(buyer, buyerInitialBalance);
        // deal stablecoin for purchase
        uint256 purchaseAmount =
            module.mintPriceToStablecoinAmount(uint256(price) * uint256(amount), address(stablecoin));
        buyerInitialStablecoinBalance = purchaseAmount + uint256(balanceOffset); // cast to prevent overflow
        stablecoin.mint(buyer, buyerInitialStablecoinBalance);
        // allow module to spend buyer's stablecoin
        vm.prank(buyer);
        stablecoin.increaseAllowance(address(module), purchaseAmount);

        ownerInitialStablecoinBalance = stablecoin.balanceOf(owner);

        return (buyer, buyerInitialBalance, buyerInitialStablecoinBalance, ownerInitialStablecoinBalance);
    }

    function initModuleAndBuyer(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
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
        return initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset, 1);
    }

    function test_mint(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, uint64 price, uint64 balanceOffset)
        public
    {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        vm.prank(buyer);
        // mint token
        uint256 tokenId = module.mint{value: fee}(address(proxy), address(stablecoin));
        // **buyer** received token
        assertEq(proxy.balanceOf(buyer), 1);
        assertEq(proxy.ownerOf(tokenId), buyer);
        assertEq(proxy.totalSupply(), 1);
        // buyer balance decreased by fee
        assertEq(buyer.balance, buyerInitialBalance - fee);
        // buyer stablecoin balance decreased by purchaseAmount
        uint256 purchaseAmount = module.mintPriceToStablecoinAmount(price, address(stablecoin));
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - purchaseAmount);
        // owner stablecoin balance increased by purchaseAmount
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance + purchaseAmount);
    }

    function test_mintTo(uint8 coinDecimals, uint8 moduleDecimals, uint64 fee, uint64 price, uint64 balanceOffset)
        public
    {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // recipient is NOT buyer
        address recipient = createAccount();

        vm.prank(buyer);
        // mint token
        uint256 tokenId = module.mintTo{value: fee}(address(proxy), address(stablecoin), recipient);
        // **recipient** received token
        assertEq(proxy.balanceOf(recipient), 1);
        assertEq(proxy.ownerOf(tokenId), recipient);
        assertEq(proxy.totalSupply(), 1);
        // buyer balance decreased by fee
        assertEq(buyer.balance, buyerInitialBalance - fee);
        // buyer stablecoin balance decreased by purchaseAmount
        uint256 purchaseAmount = module.mintPriceToStablecoinAmount(price, address(stablecoin));
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - purchaseAmount);
        // owner stablecoin balance increased by purchaseAmount
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance + purchaseAmount);
    }

    function test_mint_revert_stablecoinNotEnabled(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // disable all tokens
        vm.prank(owner);
        module.setUp(address(proxy), price, bytes16(0));

        vm.prank(buyer);
        vm.expectRevert("STABLECOIN_NOT_ENABLED");
        module.mint{value: fee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mint_revert_invalidFee(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset,
        uint64 invalidFee
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // ensure buyer has sufficient balance
        vm.deal(buyer, buyerInitialBalance + invalidFee);

        // attempt mint with invalid fee
        vm.assume(invalidFee != fee);
        vm.expectRevert("INVALID_FEE");
        vm.prank(buyer);
        module.mint{value: invalidFee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance + invalidFee);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mint_revert_missingPaymentCollector(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // disable all tokens
        vm.prank(owner);
        proxy.updatePaymentCollector(address(0));

        vm.prank(buyer);
        vm.expectRevert("MISSING_PAYMENT_COLLECTOR");
        module.mint{value: fee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mint_revert_insufficientAllowance(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // wipe stablecoin's approval for module
        vm.prank(buyer);
        stablecoin.approve(address(module), 0);

        vm.prank(buyer);
        vm.expectRevert("ERC20: insufficient allowance");
        module.mint{value: fee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mint_revert_insufficientAllowance_safeERC20(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // change to variant with no reverts
        stablecoin.toggleRevert();

        // wipe stablecoin's approval for module
        vm.prank(buyer);
        stablecoin.approve(address(module), 0);

        vm.prank(buyer);
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        module.mint{value: fee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mintTo_revert_invalidReceiver(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        vm.prank(buyer);
        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        module.mintTo{value: fee}(address(proxy), address(stablecoin), address(module));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mintTo_revert_invalidReceiver_safeERC20(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);
        // change to variant with no reverts
        stablecoin.toggleRevert();

        vm.prank(buyer);
        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        module.mintTo{value: fee}(address(proxy), address(stablecoin), address(module));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mint_revert_guardRejection(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // set guard to reject all mints
        vm.prank(owner);
        proxy.guard(Permissions.Operation.MINT, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

        vm.prank(buyer);
        vm.expectRevert("NOT_ALLOWED");
        module.mint{value: fee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mint_revert_disabledModule(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        // disable module
        vm.prank(owner);
        proxy.permit(address(module), bytes32(0));

        vm.prank(buyer);
        vm.expectRevert("NOT_PERMITTED");
        module.mint{value: fee}(address(proxy), address(stablecoin));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    function test_mintTo_revert_recipientZeroAddress(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        vm.prank(buyer);
        vm.expectRevert("ERC721: mint to the zero address");
        module.mintTo{value: fee}(address(proxy), address(stablecoin), address(0));
        // no token minted
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    /*==========
        MINT
    ==========*/

    function test_batchMint(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset,
        uint8 amount
    ) public {
        vm.assume(amount > 0);

        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset, amount);

        vm.prank(buyer);
        // mint token
        (uint256 startTokenId, uint256 endTokenId) =
            module.batchMint{value: uint256(fee) * amount}(address(proxy), address(stablecoin), amount);
        // **buyer** received token
        assertEq(proxy.balanceOf(buyer), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(proxy.ownerOf(startTokenId + i), buyer);
        }
        assertEq(proxy.totalSupply(), amount);
        assertEq(endTokenId, startTokenId + amount - 1);
        // buyer balance decreased by fee
        assertEq(buyer.balance, buyerInitialBalance - uint256(fee) * amount);
        // buyer stablecoin balance decreased by purchaseAmount
        uint256 purchaseAmount = module.mintPriceToStablecoinAmount(uint256(price) * amount, address(stablecoin));
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance - purchaseAmount);
        // owner stablecoin balance increased by purchaseAmount
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance + purchaseAmount);
    }

    function test_batchMint_revert_zeroAmount(
        uint8 coinDecimals,
        uint8 moduleDecimals,
        uint64 fee,
        uint64 price,
        uint64 balanceOffset
    ) public {
        // no tokens
        uint8 amount = 0;

        (
            address buyer,
            uint256 buyerInitialBalance,
            uint256 buyerInitialStablecoinBalance,
            uint256 ownerInitialStablecoinBalance
        ) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        vm.prank(buyer);
        // mint token
        vm.expectRevert("ZERO_AMOUNT");
        module.batchMint{value: uint256(fee) * amount}(address(proxy), address(stablecoin), amount);
        // buyer does NOT received token
        assertEq(proxy.balanceOf(buyer), 0);
        assertEq(proxy.totalSupply(), 0);
        // buyer balance unchanged
        assertEq(buyer.balance, buyerInitialBalance);
        // buyer stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(buyer), buyerInitialStablecoinBalance);
        // owner stablecoin balance unchanged
        assertEq(stablecoin.balanceOf(owner), ownerInitialStablecoinBalance);
    }

    /*==========
        FEES
    ==========*/

    function test_constructor(uint64 fee) public {
        uint8 moduleDecimals = 0;
        module = new StablecoinPurchaseModule(owner, fee, moduleDecimals, "TEST");
        // no fee balance
        assertEq(module.feeBalance(), 0);
        // fee set
        assertEq(module.fee(), fee);
        // owner set
        assertEq(module.owner(), owner);
    }

    function test_updateFee(uint64 fee1, uint64 fee2) public {
        uint8 moduleDecimals = 0;
        module = new StablecoinPurchaseModule(owner, fee1, moduleDecimals, "TEST");

        vm.prank(owner);
        module.updateFee(fee2);
        // fee set
        assertEq(module.fee(), fee2);
    }

    function test_updateFee_revert_notOwner(uint64 fee1, uint64 fee2, address randomAddress) public {
        uint8 moduleDecimals = 0;
        module = new StablecoinPurchaseModule(owner, fee1, moduleDecimals, "TEST");

        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        vm.expectRevert("Ownable: caller is not the owner");
        module.updateFee(fee2);
        // fee NOT set
        assertEq(module.fee(), fee1);
    }

    function test_withdrawFee(uint64 fee) public {
        uint8 coinDecimals = 0;
        uint8 moduleDecimals = 0;
        uint8 price = 100;
        uint8 balanceOffset = 0;
        (address buyer,,,) = initModuleAndBuyer(coinDecimals, moduleDecimals, fee, price, balanceOffset);

        vm.prank(buyer);
        // mint token
        module.mint{value: fee}(address(proxy), address(stablecoin));

        uint256 ownerInitialBalance = owner.balance;
        uint256 moduleInitialBalance = address(module).balance;
        uint256 feeBalance = module.feeBalance();
        module.withdrawFee();
        // owner balance increases
        assertEq(owner.balance, ownerInitialBalance + feeBalance);
        // module balance decreases
        assertEq(address(module).balance, moduleInitialBalance - feeBalance);
        // module feeBalance zero
        assertEq(module.feeBalance(), 0);
    }
}
