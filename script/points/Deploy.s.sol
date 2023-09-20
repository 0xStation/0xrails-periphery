// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {PointsFactory} from "../../src/points/factory/PointsFactory.sol";

contract Deploy is ScriptUtils {
    /*=================
        ENVIRONMENT 
    =================*/

    // The following contracts will be deployed:
    PointsFactory pointsFactoryImpl;
    PointsFactory pointsFactoryProxy; // proxy

    address public owner = ScriptUtils.stationFounderSafe;

    function run() public {
        vm.startBroadcast();

        /// @dev first deploy ERC20Rails from the rails repo and update the address in `deployPointsFactory`!

        string memory saltString = ScriptUtils.readSalt("salt");
        bytes32 salt = bytes32(bytes(saltString));

        pointsFactoryProxy = deployPointsFactory(salt);

        vm.stopBroadcast();
    }

    function deployPointsFactory(bytes32 salt) internal returns (PointsFactory) {
        address erc20Rails = 0x9391eD3da2645CE9B7C8d718CDB4F101fA8d9D7b; // goerli, sepolia
        // address erc20Rails = 0x5195a67ebf55e6f76f6c36e017e14a807d1f4c1d; // polygon
        pointsFactoryImpl = PointsFactory(address(new PointsFactory{salt: salt}()));

        bytes memory initFactory =
            abi.encodeWithSelector(PointsFactory.initialize.selector, erc20Rails, owner);
        return PointsFactory(address(new ERC1967Proxy{salt: salt}(address(pointsFactoryImpl), initFactory)));
    }
}
