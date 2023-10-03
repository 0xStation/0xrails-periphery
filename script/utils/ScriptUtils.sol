// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

abstract contract ScriptUtils is Script {
    struct Call3 {
        address target;
        bool allowFailure;
        bytes callData;
    }
    
    error Create2Failure();

    // global addresses
    address public constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    // valid as of 09/14/23
    address public constant turnkey = 0xBb942519A1339992630b13c3252F04fCB09D4841;
    // Station multisig (SafeProxy.sol)
    address public constant stationFounderSafe = 0xDd70fb41e936c5dc67Fc783BA5281E50f0A46fBC;
    // Multicall3 contract address across almost all chains
    address public constant multicall3 = 0xcA11bde05977b3631167028862bE2a173976CA11;

    // dev addresses
    address public constant symmetry = 0x7ff6363cd3A4E7f9ece98d78Dd3c862bacE2163d;
    address public constant frog = 0xE7affDB964178261Df49B86BFdBA78E9d768Db6D;
    address public constant paprika = 0x4b8c47aE2e5083EE6AA9aE2884E8051c2e4741b1;
    address public constant robriks = 0xFFFFfFfFA2eC6F66a22017a0Deb0191e5F8cBc35;

    // reads a plain extensionless file containing *only the salt string*
    function readSalt(string memory fileName) internal view returns (string memory) {
        string memory inputDir = "./script/input/";
        string memory file = string.concat(inputDir, fileName);
        return vm.readFile(file);
    }

    // write used salts to an output file upon completion of scripts that used `readSalt()`
    function writeUsedSalt(string memory consumedSalt, string memory deployment) internal {
        // eg. "GarlicSalt : ERC721Mage, "
        string memory output = string.concat(consumedSalt, " : ", deployment, ", ");
        string memory dest = "./script/input/usedSalts";
        return vm.writeLine(dest, output);
    }
}
