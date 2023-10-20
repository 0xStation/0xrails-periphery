// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20Rails} from "0xrails/cores/ERC20/interface/IERC20Rails.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {PermitController} from "src/lib/module/PermitController.sol";

/// @title Station FreeMintController Contract
/// @author symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth
/// @dev Mint ERC20 tokens for free with signature-based authentication
contract FreeMintController is PermitController {

    constructor() PermitController() {}

    /// @dev Function to mint a single collection token to a specified recipient
    function mintTo(address collection, address recipient, uint256 amount) external payable usePermits(_encodePermitContext(collection)) {
        require(amount > 0, "ZERO_AMOUNT");
        IERC20Rails(collection).mintTo(recipient, amount);
    }

    /*=============
        PERMITS
    =============*/

    function _encodePermitContext(address collection) internal pure returns (bytes memory context) {
        return abi.encode(collection);
    }

    function _decodePermitContext(bytes memory context) internal pure returns (address collection) {
        return abi.decode(context, (address));
    }

    function signerCanPermit(address signer, bytes memory context) public view override returns (bool) {
        address collection = _decodePermitContext(context);
        return IPermissions(collection).hasPermission(Operations.MINT_PERMIT, signer);
    }

    function requirePermits(bytes memory context) public view override returns (bool) {
        return true;
    }
}
