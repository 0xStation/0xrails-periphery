// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {BadgesFactory} from "../../src/badges/factory/BadgesFactory.sol";

contract Deploy is Script {
    address public turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    address public frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public sym = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;

    address public owner = sym;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        /// @dev first deploy ERC1155Mage from the mage repo and update the address in `deployBadgesFactory`!

        deployBadgesFactory();

        vm.stopBroadcast();
    }

    function deployBadgesFactory() internal returns (address) {
        address badgesImpl = 0x5195A67eBf55E6f76F6c36E017e14a807d1f4c1D; // goerli
        // address badgesImpl = 0x5195a67ebf55e6f76f6c36e017e14a807d1f4c1d; // polygon
        address badgesFactoryImpl = address(new BadgesFactory());

        bytes memory initFactory =
            abi.encodeWithSelector(BadgesFactory(badgesFactoryImpl).initialize.selector, badgesImpl, owner);
        return address(new ERC1967Proxy(badgesFactoryImpl, initFactory));
    }
}
