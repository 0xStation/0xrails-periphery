// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/lib/renderer/Renderer.sol";
import { Membership } from "../src/membership/Membership.sol";
import "../src/membership/MembershipFactory.sol";
import "../src/modules/FixedStablecoinPurchaseModule.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract ERC20Decimals is ERC20 {
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}


contract PaymentModuleTest is Test {
    address public membershipFactory;
    address public rendererImpl;
    address public membershipImpl;
    address public fixedStablecoinPurchaseModuleImpl;
    address public fakeERC20Six;
    address public fakeERC20Eighteen;
    uint256 fee = 0.0007 ether;

    function setUp() public {
        startHoax(address(1));
        rendererImpl = address(new Renderer(address(1), "https://tokens.station.express"));
        membershipImpl = address(new Membership());
        membershipFactory = address(new MembershipFactory(membershipImpl, address(1)));
        fixedStablecoinPurchaseModuleImpl = address(new FixedStablecoinPurchaseModule(address(1), fee, "USD"));
        fakeERC20Six = address(new ERC20Decimals("FakeUSDC", "USDC", 6));
        fakeERC20Eighteen = address(new ERC20("FakeDAI", "DAI"));
        vm.stopPrank();
    }

    // meaning: I shouldn't be able to mint if I'm not the owner of the contract
    // I shouldn't be able to mint without the module as a non-owner
    function test_mint_without_adding_payment_module_should_fail() public {
        startHoax(address(2));
        address membership =
            MembershipFactory(membershipFactory).create(address(1), rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);

        vm.expectRevert("NOT_PERMITTED");
        membershipContract.mintTo(address(2));
        vm.stopPrank();
    }

    function test_add_module_and_mint(uint256 price) public {
        vm.assume(price < 2 ** 128);
        startHoax(address(1));
        address membership =
            MembershipFactory(membershipFactory).create(address(1), rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        FixedStablecoinPurchaseModule paymentModule = FixedStablecoinPurchaseModule(fixedStablecoinPurchaseModuleImpl);
        paymentModule.setup(membership, membership, price);

        Permissions.Operation[] memory operations = new Permissions.Operation[](1);
        operations[0] = Permissions.Operation.MINT;
        membershipContract.permit(fixedStablecoinPurchaseModuleImpl, membershipContract.permissionsValue(operations));

        paymentModule.mint{value: price + fee}(membership);

        assertEq(membershipContract.ownerOf(0), address(1));
        vm.stopPrank();
    }
}
