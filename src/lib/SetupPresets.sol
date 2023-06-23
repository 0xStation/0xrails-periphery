// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Permissions} from "./Permissions.sol";
import {IMembershipFactory} from "../membership/IMembershipFactory.sol";

library SetupPresets {

    address internal constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    bytes32 public constant ntHash = keccak256("nt");
    bytes public constant nt = abi.encodeWithSelector(
        Permissions.guard.selector,
        Permissions.Operation.TRANSFER,
        MAX_ADDRESS
    );

    bytes32 public constant opaHash = keccak256("opa");
    function opa(address _onePerAddress) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.guard.selector,
            Permissions.Operation.MINT,
            _onePerAddress
        );
    }

    function _operationBit(Permissions.Operation operation) internal pure returns (bytes32) {
        return bytes32(1 << uint8(operation));
    }

    bytes32 public constant gsmHash = keccak256("gsm");
    function gsm(address _turnkey) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.permit.selector, 
            _turnkey,
            _operationBit(Permissions.Operation.MINT)
        );
    } 

    bytes32 public constant grantHash = keccak256("grant");
    function grant(address _grant) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.permit.selector,
            _grant,
            _operationBit(Permissions.Operation.GRANT)
        );
    }

    bytes32 public constant freeHash = keccak256("free");
    function free(address _publicFreeMintModule) public pure returns (bytes memory) {
        return abi.encodeWithSelector(
            Permissions.permit.selector,
            _publicFreeMintModule,
            _operationBit(Permissions.Operation.MINT) // only mint
        );
    }

    bytes32 public constant ntOpaHash = keccak256("nt+opa");
    bytes32 public constant ntOpaGrantHash = keccak256("nt+opa+grant");
    bytes32 public constant ntOpaGsmHash = keccak256("nt+opa+gsm");
    bytes32 public constant ntOpaGrantFreeHash = keccak256("nt+opa+grant+free");

    // sets up presets for the membership factory 
    // 5 presets with single calls - nt, opa, turnkey, free
    // 1 preset with 2 calls - nt+opa
    // 2 presets with 3 calls - nt+opa+grant, nt+opa+gsm
    // 1 preset with 1 calls - nt+opa+grant+free
    function setupPresets(address _membershipFactory, address _onePerAddress, address _turnKey, address _publicFreeMintModule) public {

        // 5 presets with single calls
        bytes[] memory bytesArr = new bytes[](1);

        bytesArr[0] = nt;
        IMembershipFactory(_membershipFactory).addPreset(ntHash, bytesArr);

        bytesArr[0] = opa(_onePerAddress);
        IMembershipFactory(_membershipFactory).addPreset(opaHash, bytesArr);

        bytesArr[0] = gsm(_turnKey);
        IMembershipFactory(_membershipFactory).addPreset(gsmHash, bytesArr);

        bytesArr[0] = grant(_turnKey);
        IMembershipFactory(_membershipFactory).addPreset(grantHash, bytesArr);

        bytesArr[0] = free(_publicFreeMintModule);
        IMembershipFactory(_membershipFactory).addPreset(freeHash, bytesArr);


        // 1 preset with 2 calls
        bytesArr = new bytes[](2);

        bytesArr[0] = nt;
        bytesArr[1] = opa(_onePerAddress);
        IMembershipFactory(_membershipFactory).addPreset(ntOpaHash, bytesArr);

        // 2 presets with 3 calls
        bytesArr = new bytes[](3);
        bytesArr[0] = nt;
        bytesArr[1] = opa(_onePerAddress);
        bytesArr[2] = grant(_turnKey);
        IMembershipFactory(_membershipFactory).addPreset(ntOpaGrantHash, bytesArr);

        bytesArr[2] = gsm(_turnKey);
        IMembershipFactory(_membershipFactory).addPreset(ntOpaGsmHash, bytesArr);

        // 1 preset with 4 calls
        bytesArr = new bytes[](4);
        bytesArr[0] = nt;
        bytesArr[1] = opa(_onePerAddress);
        bytesArr[2] = grant(_turnKey);
        bytesArr[3] = free(_publicFreeMintModule);
        IMembershipFactory(_membershipFactory).addPreset(ntOpaGrantFreeHash, bytesArr);

    }
}