// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Badge} from "src/badge/Badge.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin-contracts-upgradeable/token/ERC1155/utils/ERC1155ReceiverUpgradeable.sol";


/// @notice Test contract for batch calling mechanism on the implementing contract
contract BadgeTest is Test, ERC1155ReceiverUpgradeable {
    Badge public badgeImpl;
    Badge public proxy;
    Badge public pwndProxy;
    
    // init vars
    address owner;
    address renderer;
    uint256 reenterCount;
    string name;
    string symbol;

    function setUp() public {
        badgeImpl = new Badge();
        owner = address(0xdeadbeef);
        renderer = address(0xbadbeef);
        name = "Example";
        symbol = "EX";

        bytes memory initData = abi.encodeWithSelector(badgeImpl.init.selector, owner, renderer, name, symbol);
        proxy = Badge(address(new ERC1967Proxy(address(badgeImpl), initData)));
    }

    // see malicious onERC1155Received() implementation below
    function test_ownerMintReentrancy() public {
        // configure victim proxy using this test contract as owner
        bytes memory initData = abi.encodeWithSelector(badgeImpl.init.selector, address(this), renderer, name, symbol);
        pwndProxy = Badge(address(new ERC1967Proxy(address(badgeImpl), initData)));

        uint256 id = 0;
        uint256 amount = 1;
        uint256 reenterAmt = type(uint256).max / 4;
        pwndProxy.mintTo(address(this), id, amount);

        // assert reentrancy was successful
        uint256 balance = pwndProxy.balanceOf(address(this), 0);
        assertEq(balance, reenterAmt * 3 + amount);
    }

    // Malicious ERC1155Receiver override implementations to demonstrate reentrancy irrelevance
    // Safe as this attack can only be carried out by the owner
    // Only consideration is potential obfuscation of bad intent w/ benign calldata a la Tornado governance incident
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) public override returns (bytes4) {
        if (reenterCount < 3) {
            ++reenterCount;
            pwndProxy.mintTo(address(this), 0, type(uint256).max / 4);
        }
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) public pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}