// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Access} from "mage/access/Access.sol";
import {Extension} from "mage/extension/Extension.sol";

import {IMetadataRouter} from "../../../metadataRouter/IMetadataRouter.sol";
import {IPayoutAddressExtensionExternal} from "./IPayoutAddressExtension.sol";
import {PayoutAddressExtensionInternal} from "./PayoutAddressExtensionInternal.sol";
import {PayoutAddressExtensionStorage} from "./PayoutAddressExtensionStorage.sol";

contract PayoutAddressExtension is
    Extension,
    Access,
    PayoutAddressExtensionInternal,
    IPayoutAddressExtensionExternal
{
    /// @dev change metadataRouter constant to real address prior to deploying
    address public immutable metadataRouter;

    constructor(address router) Extension() {
        metadataRouter = router;
    }

    /*===============
        EXTENSION
    ===============*/

    function contractURI() public view override returns (string memory uri) {
        return IMetadataRouter(metadataRouter).contractURI(address(this));
    }

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
        _setPayoutAddress(payoutAddress);
    }

    /*====================
        AUTHORITZATION
    ====================*/

    // make public with return to be callable by UIs to enable/disable input
    function checkCanUpdatePayoutAddress() public virtual returns (bool) {
        /// @dev TODO: what happens with virtual owner() from Access??
        /// @dev maybe need Access to make an external self-call to use whatever owner() implementation
        _checkSenderIsAdmin();
        return true;
    }
}
