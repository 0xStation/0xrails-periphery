// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPayoutAddressExtensionInternal} from "./IPayoutAddressExtension.sol";
import {PayoutAddressExtensionStorage} from "./PayoutAddressExtensionStorage.sol";

abstract contract PayoutAddressExtensionInternal is IPayoutAddressExtensionInternal {
    /*===========
        VIEWS
    ===========*/
    function payoutAddress() public view virtual returns (address) {
        PayoutAddressExtensionStorage.Layout storage layout = PayoutAddressExtensionStorage.layout();
        return layout.payoutAddress;
    }

    /*=============
        SETTERS
    =============*/

    function _setPayoutAddress(address newPayoutAddress) internal {
        if (newPayoutAddress == address(0)) revert PayoutAddressIsZero();
        PayoutAddressExtensionStorage.Layout storage layout = PayoutAddressExtensionStorage.layout();
        emit PayoutAddressUpdated(layout.payoutAddress, newPayoutAddress);
        layout.payoutAddress = newPayoutAddress;
    }

    /*====================
        AUTHORITZATION
    ====================*/
}
