// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC721Mage} from "mage/cores/ERC721/ERC721Mage.sol";
import {Operations} from "mage/lib/Operations.sol";

import {FreeMintModule} from "src/membership/modules/FreeMintModule.sol";
import {OnePerAddressGuard} from "src/membership/guards/OnePerAddressGuard.sol";
import {SetUpMembership} from "test/lib/SetUpMembership.sol";

contract OnePerAddressGuardTest is Test, SetUpMembership {
    ERC721Mage public proxy;
    OnePerAddressGuard public guard;

    // intended to contain custom error signatures
    bytes public err;

    function setUp() public override {
        SetUpMembership.setUp(); // implementation, factory, extensions
        guard = new OnePerAddressGuard(address(0));
        proxy = SetUpMembership.create();
        
        vm.startPrank(owner);
        proxy.setGuard(Operations.MINT, address(guard));
        proxy.setGuard(Operations.TRANSFER, address(guard));
        vm.stopPrank();
    }

    function test_mint() public {
        address to = owner;
        
        vm.prank(owner);
        proxy.mintTo(to, 1);

        assertEq(proxy.balanceOf(to), 1);
        assertEq(proxy.totalSupply(), 1);
    }

    function test_mintRevertOnePerAddress(uint16 quantity) public {
        address to = owner;
        vm.assume(to != address(0));
        vm.assume(quantity > 1);

        vm.expectRevert(abi.encodeWithSelector(OnePerAddressGuard.OnePerAddress.selector, to, quantity));
        vm.prank(owner);
        proxy.mintTo(to, quantity);

        assertEq(proxy.balanceOf(to), 0);
        assertEq(proxy.totalSupply(), 0);
    }

    function test_transfer() public {
        address from = owner;
        address to = createAccount();
        
        vm.prank(owner);
        proxy.mintTo(from, 1);

        vm.prank(from);
        proxy.safeTransferFrom(from, to, 1);
        
        assertEq(proxy.balanceOf(from), 0);
        assertEq(proxy.balanceOf(to), 1);
    }
    
    function test_transferRevertOnePerAddress() public {
        address from = owner;
        address to = createAccount();
        
        vm.startPrank(owner);
        proxy.mintTo(from, 1);
        proxy.mintTo(to, 1);
        vm.expectRevert(abi.encodeWithSelector(OnePerAddressGuard.OnePerAddress.selector, to, 2));
        proxy.safeTransferFrom(from, to, 1);
        vm.stopPrank();
        
        assertEq(proxy.balanceOf(from), 1);
        assertEq(proxy.balanceOf(to), 1);
    }
}
