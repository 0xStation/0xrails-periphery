// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BadgesFactory} from "../../src/badges/factory/BadgesFactory.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

contract Deploy is ScriptUtils {
    /*=================
        ENVIRONMENT 
    =================*/

    // The following contracts will be deployed:
    BadgesFactory badgesFactoryImpl;
    BadgesFactory badgesFactoryProxy; // proxy

    address public owner = ScriptUtils.stationFounderSafe;

    function run() public {
        vm.startBroadcast();

        /// @dev first deploy ERC1155Rails from the 0xrails repo and update the address in `deployBadgesFactory`!

        string memory saltString = ScriptUtils.readSalt("salt");
        bytes32 salt = bytes32(bytes(saltString));

        badgesFactoryProxy = deployBadgesFactory(salt);

        vm.stopBroadcast();

        writeUsedSalt(saltString, string.concat("BadgesFactoryImpl @", Strings.toHexString(address(badgesFactoryImpl))));
        writeUsedSalt(saltString, string.concat("BadgesFactoryProxy @", Strings.toHexString(address(badgesFactoryProxy))));
    }

    function deployBadgesFactory(bytes32 salt) internal returns (BadgesFactory) {
        // address badgesImpl = 0xb902C5610f6eE3206b6aC29579A411783AD5CB21; // erc1155rails on goerli, sepolia
        // address badgesImpl = 0xfC6Eea2467f921C66063C8E2aDB193c44299e869; // erc1155rails on polygon
        address badgesImpl = 0x0070Ac819452f7F5a0d02FF3c9c7A8BcfE7Bba14; // erc1155rails on Linea
        badgesFactoryImpl = new BadgesFactory{salt: salt}();

        bytes memory initFactory =
            abi.encodeWithSelector(BadgesFactory.initialize.selector, badgesImpl, owner);
        return BadgesFactory(address(new ERC1967Proxy{salt: salt}(address(badgesFactoryImpl), initFactory)));
    }
}
