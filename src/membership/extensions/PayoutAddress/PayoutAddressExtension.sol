// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Extension} from "0xrails/extension/Extension.sol";

import {ContractMetadata} from "../../../lib/ContractMetadata.sol";
import {PayoutAddress} from "./PayoutAddress.sol";

contract PayoutAddressExtension is PayoutAddress, Extension, ContractMetadata {
    /*=======================
        CONTRACT METADATA
    =======================*/

    constructor(address router) Extension() ContractMetadata(router) {}

    function _contractRoute() internal pure override returns (string memory route) {
        return "extension";
    }

    /*===============
        EXTENSION
    ===============*/

    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](3);
        selectors[0] = this.payoutAddress.selector;
        selectors[1] = this.updatePayoutAddress.selector;
        selectors[2] = this.removePayoutAddress.selector;

        return selectors;
    }

    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.payoutAddress.selector) {
            return "payoutAddress()";
        } else if (selector == this.updatePayoutAddress.selector) {
            return "updatePayoutAddress(address)";
        } else if (selector == this.removePayoutAddress.selector) {
            return "removePayoutAddress()";
        } else {
            return "";
        }
    }
}
