// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/lib/renderer/Renderer.sol";
import { Membership } from "../src/membership/Membership.sol";
import "../src/membership/MembershipFactory.sol";
import "../src/modules/FixedStablecoinPurchaseModule.sol";
import { ERC20 } from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract ERC20Decimals is ERC20 {
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ERC20Minter is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract PaymentModuleTest is Test {
    address public membershipFactory;
    address public rendererImpl;
    address public membershipImpl;
    address public membershipInstance;
    Membership public membershipContract;
    address public fixedStablecoinPurchaseModuleImpl;
    FixedStablecoinPurchaseModule public paymentModule;

    address public fakeUSDCImpl;
    address public fakeDAIImpl;
    uint256 fee = 0.0007 ether;

    function setUp() public {
        startHoax(address(12));
        rendererImpl = address(new Renderer(address(12), "https://tokens.station.express"));
        membershipImpl = address(new Membership());
        membershipFactory = address(new MembershipFactory(membershipImpl, address(12)));
        fixedStablecoinPurchaseModuleImpl = address(new FixedStablecoinPurchaseModule(address(12), fee, "USD", 2));
        paymentModule = FixedStablecoinPurchaseModule(fixedStablecoinPurchaseModuleImpl);
        fakeUSDCImpl = address(new ERC20Decimals("FakeUSDC", "USDC", 6));
        fakeDAIImpl = address(new ERC20Minter("FakeDAI", "DAI"));
        membershipInstance =
            MembershipFactory(membershipFactory).create(address(12), rendererImpl, "Friends of Station", "FRIENDS");
        membershipContract = Membership(membershipInstance);

        Permissions.Operation[] memory operations = new Permissions.Operation[](1);
        operations[0] = Permissions.Operation.MINT;
        membershipContract.permit(fixedStablecoinPurchaseModuleImpl, membershipContract.permissionsValue(operations));

         // give account fake DAI + fake USDC
        ERC20Minter(fakeDAIImpl).mint(address(12), 1000 * 10 ** 18);
        ERC20(fakeDAIImpl).approve(fixedStablecoinPurchaseModuleImpl, 1000 * 10 ** 18);
        ERC20Minter(fakeUSDCImpl).mint(address(12), 1000 * 10 ** 6);
        ERC20(fakeUSDCImpl).approve(fixedStablecoinPurchaseModuleImpl, 1000 * 10 ** 6);
        vm.stopPrank();
    }

    // 1. token exists but is not enabled for collection
    // 2. the token doesnt exist at the module level
    function test_stablecoinEnabled() public {
        startHoax(address(12));
        paymentModule.append(fakeUSDCImpl);
        paymentModule.append(fakeDAIImpl);
        assertEq(paymentModule.stablecoinEnabled(membershipImpl, fakeUSDCImpl), true);
        assertEq(paymentModule.stablecoinEnabled(membershipImpl, fakeDAIImpl), true);
        vm.stopPrank();
    }

    // WHAT HAPPENS IF WE ENABLE TOKENS THAT ARE NOT YET APPENDED?
    function test_enabledTokensValue() public {
        startHoax(address(12));
        paymentModule.append(fakeUSDCImpl);
        paymentModule.append(fakeDAIImpl);
        address[] memory enabledTokens = new address[](2);
        enabledTokens[0] = fakeUSDCImpl;
        enabledTokens[1] = fakeDAIImpl;
        assertEq(paymentModule.enabledTokensValue(enabledTokens), bytes32(uint256(3)));
        vm.stopPrank();
    }

    function test_append_mint() public {
        uint256 price = 10;
        startHoax(address(12));
        paymentModule.append(fakeUSDCImpl);
        paymentModule.append(fakeDAIImpl);
        address[] memory enabledTokens = new address[](2);
        enabledTokens[0] = fakeUSDCImpl;
        enabledTokens[1] = fakeDAIImpl;
        paymentModule.setup(membershipInstance, address(2), price, paymentModule.enabledTokensValue(enabledTokens));
        paymentModule.mint{value: fee}(membershipInstance, fakeDAIImpl);
        // ensure token was minted
        assertEq(membershipContract.ownerOf(1), address(12));
        // ensure erc20 is spent
        assertEq(ERC20(fakeDAIImpl).balanceOf(address(12)), 1000 - price);
        // ensure erc20 is received
        assertEq(ERC20(fakeDAIImpl).balanceOf(address(2)), price);
        vm.stopPrank();
    }

    function test_withdrawFee() public {
      uint256 price = 10;
        startHoax(address(12));
        paymentModule.append(fakeUSDCImpl);
        paymentModule.append(fakeDAIImpl);
        paymentModule.setup(membershipInstance, address(2), price, bytes32(uint256(3)));
        paymentModule.mint{value: fee}(membershipInstance, fakeDAIImpl);
        uint256 beforeWithdrawBalance = address(12).balance;
        paymentModule.withdrawFee();
        assertEq(address(12).balance, beforeWithdrawBalance + fee);
        vm.stopPrank();
    }
}
