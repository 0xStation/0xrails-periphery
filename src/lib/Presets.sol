// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Permissions} from "./Permissions.sol";
import {IMembershipFactory} from "../membership/IMembershipFactory.sol";

library Presets {

    address internal constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    bytes public constant nt = abi.encodeWithSelector(
        Permissions.guard.selector,
        Permissions.Operation.TRANSFER,
        MAX_ADDRESS
    );

    function opa(address _onePerAddress) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.guard.selector,
            Permissions.Operation.MINT,
            _onePerAddress
        );
    }

    function turnKey(address _turnKey) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.permit.selector,
            _turnKey,
            Permissions.Operation.MINT
        );
    }

    function free(address _publicFreeMintModule) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.permit.selector,
            _publicFreeMintModule,
            Permissions.Operation.MINT
        );
    }

    // sets up presets for the membership factory 
    // 4 presets with single calls - nt, opa, turnkey, free
    // 1 presets with 2 calls - nt+opa
    // 2 presets with 3 calls - nt+opa+turnkey, nt+opa+free
    function setupPresets(address _membershipFactory, address _onePerAddress, address _turnKey, address _publicFreeMintModule) public {

        // 4 presets with single calls
        bytes[] memory bytesArr = new bytes[](1);

        bytesArr[0] = nt;
        IMembershipFactory(_membershipFactory).addPreset("nt", bytesArr);

        bytesArr[0] = opa(_onePerAddress);
        IMembershipFactory(_membershipFactory).addPreset("opa", bytesArr);

        bytesArr[0] = turnKey(_turnKey);
        IMembershipFactory(_membershipFactory).addPreset("turnkey", bytesArr);

        bytesArr[0] = free(_publicFreeMintModule);
        IMembershipFactory(_membershipFactory).addPreset("free", bytesArr);



        // 1 preset with 2 calls
        bytesArr = new bytes[](2);

        bytesArr[0] = nt;
        bytesArr[1] = opa(_onePerAddress);
        IMembershipFactory(_membershipFactory).addPreset("nt+opa", bytesArr);



        // 2 presets with 3 calls
        bytesArr = new bytes[](3);
        bytesArr[0] = nt;
        bytesArr[1] = opa(_onePerAddress);
        bytesArr[2] = turnKey(_turnKey);
        IMembershipFactory(_membershipFactory).addPreset("nt+opa+turnkey", bytesArr);

        bytesArr[2] = free(_publicFreeMintModule);
        IMembershipFactory(_membershipFactory).addPreset("nt+opa+free", bytesArr);

    }
}