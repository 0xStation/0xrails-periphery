// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPermissions} from "mage/access/permissions/interface/IPermissions.sol";
import {Operations} from "mage/lib/Operations.sol";
import {Extension} from "mage/extension/Extension.sol";

import {ContractMetadata} from "../../../lib/ContractMetadata.sol";
import {IPayoutAddressExtensionExternal} from "./IPayoutAddressExtension.sol";
import {PayoutAddressExtensionInternal} from "./PayoutAddressExtensionInternal.sol";
import {PayoutAddressExtensionStorage} from "./PayoutAddressExtensionStorage.sol";

contract PayoutAddressExtension is Extension, ContractMetadata, PayoutAddressExtensionInternal, IPayoutAddressExtensionExternal {
    constructor(address router) Extension() ContractMetadata(router) {}

    /*===============
        EXTENSION
    ===============*/

    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](2);
        selectors[0] = this.payoutAddress.selector;
        selectors[1] = this.updatePayoutAddress.selector;

        return selectors;
    }

    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.payoutAddress.selector) {
            return "payoutAddress()";
        } else if (selector == this.updatePayoutAddress.selector) {
            return "updatePayoutAddress(address)";
        } else {
            return "";
        }
    }

    /*=============
        SETTERS
    =============*/

    function updatePayoutAddress(address payoutAddress) external virtual {
        checkCanUpdatePayoutAddress();
        if (payoutAddress == address(0)) revert PayoutAddressIsZero();
        _setPayoutAddress(payoutAddress);
    }

    function removePayoutAddress() external virtual {
        checkCanUpdatePayoutAddress();
        _setPayoutAddress(address(0));
    }

    /*====================
        AUTHORITZATION
    ====================*/

    // make public with return to be callable by UIs to enable/disable input
    function checkCanUpdatePayoutAddress() public virtual returns (bool) {
        IPermissions(address(this)).hasPermission(Operations.ADMIN, msg.sender);
        return true;
    }
}
