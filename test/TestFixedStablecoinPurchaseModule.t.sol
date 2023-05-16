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
    address public fixedStablecoinPurchaseModuleImpl;
    address public fakeUSDCImpl;
    address public fakeDAIImpl;
    uint256 fee = 0.0007 ether;

    function setUp() public {
        startHoax(address(1));
        rendererImpl = address(new Renderer(address(1), "https://tokens.station.express"));
        membershipImpl = address(new Membership());
        membershipFactory = address(new MembershipFactory(membershipImpl, address(1)));
        fixedStablecoinPurchaseModuleImpl = address(new FixedStablecoinPurchaseModule(address(1), fee, "USD"));
        fakeUSDCImpl = address(new ERC20Decimals("FakeUSDC", "USDC", 6));
        fakeDAIImpl = address(new ERC20Minter("FakeDAI", "DAI"));
        vm.stopPrank();
    }

    function test_add_module_and_mint() public {
        startHoax(address(1));
        address membership =
            MembershipFactory(membershipFactory).create(address(1), rendererImpl, "Friends of Station", "FRIENDS");
        Membership membershipContract = Membership(membership);
        FixedStablecoinPurchaseModule paymentModule = FixedStablecoinPurchaseModule(fixedStablecoinPurchaseModuleImpl);
        paymentModule.append(fakeUSDCImpl);
        paymentModule.append(fakeDAIImpl);
        paymentModule.setup(membership, membership, 10, bytes32(uint256(3)));

        Permissions.Operation[] memory operations = new Permissions.Operation[](1);
        operations[0] = Permissions.Operation.MINT;
        membershipContract.permit(fixedStablecoinPurchaseModuleImpl, membershipContract.permissionsValue(operations));

        // give account fake DAI
        ERC20Minter(fakeDAIImpl).mint(address(1), 10000000000);
        // approve fake DAI to payment module
        ERC20(fakeDAIImpl).approve(fixedStablecoinPurchaseModuleImpl, 10000000000);

        paymentModule.mint{value: fee}(membership, fakeDAIImpl);
        assertEq(membershipContract.ownerOf(1), address(1));
        vm.stopPrank();
    }
}
