// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC1155Rails} from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {Operations} from "0xrails/lib/Operations.sol";

import {FreeMintController} from "src/membership/modules/FreeMintController.sol";
import {ERC1155TokenManagerTransferGuard} from "src/token/guard/ERC1155TokenManagerTransferGuard.sol";
import {SetUpERC1155Rails} from "test/lib/SetUpERC1155Rails.sol";

contract ERC1155TokenManagerTransferGuardTest is Test, SetUpERC1155Rails {
    ERC1155Rails public proxy;
    ERC1155TokenManagerTransferGuard public guard;

    // intended to contain custom error signatures
    bytes public err;

    function setUp() public override {
        SetUpERC1155Rails.setUp(); // implementation, factory, extensions
        guard = new ERC1155TokenManagerTransferGuard();
        proxy = SetUpERC1155Rails.create();

        vm.startPrank(owner);
        proxy.setGuard(Operations.TRANSFER, address(guard));
        vm.stopPrank();
    }

    function test_transferRevertManagerZero() public {
        address operator = createAccount();
        address from = createAccount();
        address to = createAccount();
        uint256 tokenId = 1;

        vm.startPrank(owner);
        proxy.mintTo(from, tokenId, 1);
        // give operator transfer permision to void approvals
        proxy.addPermission(Operations.TRANSFER, operator);
        vm.stopPrank();

        vm.startPrank(operator);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC1155TokenManagerTransferGuard.NotTokenManager.selector, tokenId, operator, from, to
            )
        );
        proxy.safeTransferFrom(from, to, tokenId, 1, bytes(""));
        vm.stopPrank();

        assertEq(proxy.balanceOf(from, tokenId), 1);
        assertEq(proxy.balanceOf(to, tokenId), 0);
    }

    function test_transferRevertManagerInvalid() public {
        address operator = createAccount();
        address from = createAccount();
        address to = createAccount();
        uint256 tokenId = 1;
        address manager = createAccount(); // entropy makes manager != from and != to
        uint256[] memory tokenIds = new uint256[](1);
        address[] memory managers = new address[](1);
        tokenIds[0] = tokenId;
        managers[0] = manager;

        vm.startPrank(owner);
        guard.setUp(address(proxy), tokenIds, managers);
        proxy.mintTo(from, tokenId, 1);
        // give operator transfer permision to void approvals
        proxy.addPermission(Operations.TRANSFER, operator);
        vm.stopPrank();

        vm.startPrank(operator);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC1155TokenManagerTransferGuard.NotTokenManager.selector, tokenId, operator, from, to
            )
        );
        proxy.safeTransferFrom(from, to, tokenId, 1, bytes(""));
        vm.stopPrank();

        assertEq(proxy.balanceOf(from, tokenId), 1);
        assertEq(proxy.balanceOf(to, tokenId), 0);
    }

    function test_transferManagerOperator() public {
        address operator = createAccount();
        address from = createAccount();
        address to = createAccount();
        uint256 tokenId = 1;
        address manager = operator;
        uint256[] memory tokenIds = new uint256[](1);
        address[] memory managers = new address[](1);
        tokenIds[0] = tokenId;
        managers[0] = manager;

        vm.startPrank(owner);
        guard.setUp(address(proxy), tokenIds, managers);
        proxy.mintTo(from, tokenId, 1);
        // give operator transfer permision to void approvals
        proxy.addPermission(Operations.TRANSFER, operator);
        vm.stopPrank();

        vm.startPrank(operator);
        proxy.safeTransferFrom(from, to, tokenId, 1, bytes(""));
        vm.stopPrank();

        assertEq(proxy.balanceOf(from, tokenId), 0);
        assertEq(proxy.balanceOf(to, tokenId), 1);

        // test sending back token not as operator
        vm.startPrank(to);
        vm.expectRevert(
            abi.encodeWithSelector(ERC1155TokenManagerTransferGuard.NotTokenManager.selector, tokenId, to, to, from)
        );
        proxy.safeTransferFrom(to, from, tokenId, 1, bytes(""));
        vm.stopPrank();
    }

    function test_transferManagerFrom() public {
        address operator = createAccount();
        address from = createAccount();
        address to = createAccount();
        address other = createAccount();
        uint256 tokenId = 1;
        address manager = from;
        uint256[] memory tokenIds = new uint256[](1);
        address[] memory managers = new address[](1);
        tokenIds[0] = tokenId;
        managers[0] = manager;

        vm.startPrank(owner);
        guard.setUp(address(proxy), tokenIds, managers);
        proxy.mintTo(from, tokenId, 1);
        // give operator transfer permision to void approvals
        proxy.addPermission(Operations.TRANSFER, operator);
        vm.stopPrank();

        vm.startPrank(operator);
        proxy.safeTransferFrom(from, to, tokenId, 1, bytes(""));
        vm.stopPrank();

        assertEq(proxy.balanceOf(from, tokenId), 0);
        assertEq(proxy.balanceOf(to, tokenId), 1);

        // test sending token to another address
        vm.startPrank(to);
        vm.expectRevert(
            abi.encodeWithSelector(ERC1155TokenManagerTransferGuard.NotTokenManager.selector, tokenId, to, to, other)
        );
        proxy.safeTransferFrom(to, other, tokenId, 1, bytes(""));
        vm.stopPrank();
    }

    function test_transferManagerTo() public {
        address operator = createAccount();
        address from = createAccount();
        address to = createAccount();
        address other = createAccount();
        uint256 tokenId = 1;
        address manager = to;
        uint256[] memory tokenIds = new uint256[](1);
        address[] memory managers = new address[](1);
        tokenIds[0] = tokenId;
        managers[0] = manager;

        vm.startPrank(owner);
        guard.setUp(address(proxy), tokenIds, managers);
        proxy.mintTo(from, tokenId, 2);
        // give operator transfer permision to void approvals
        proxy.addPermission(Operations.TRANSFER, operator);
        vm.stopPrank();

        vm.startPrank(operator);
        proxy.safeTransferFrom(from, to, tokenId, 1, bytes(""));
        vm.stopPrank();

        assertEq(proxy.balanceOf(from, tokenId), 1);
        assertEq(proxy.balanceOf(to, tokenId), 1);

        // test sending token to another address
        vm.startPrank(from);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC1155TokenManagerTransferGuard.NotTokenManager.selector, tokenId, from, from, other
            )
        );
        proxy.safeTransferFrom(from, other, tokenId, 1, bytes(""));
        vm.stopPrank();
    }
}
