// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Rails} from "0xrails/Rails.sol";
import {Ownable, OwnableInternal} from "0xrails/access/ownable/Ownable.sol";
import {Access} from "0xrails/access/Access.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";

import {ERC6551AccountGroup} from "./ERC6551AccountGroup.sol";
import {IERC6551AccountGroupRails} from "../interface/IERC6551AccountGroupRails.sol";

contract ERC6551AccountGroupRails is ERC6551AccountGroup, Rails, Initializable, Ownable, IERC6551AccountGroupRails {
    function initialize(address owner_, address initializerImpl_) external initializer {
        _transferOwnership(owner_);
        _setAccountInitializer(initializerImpl_);
    }

    /// @dev Owner address is implemented using the `OwnableInternal` contract's function
    function owner() public view override(Access, OwnableInternal) returns (address) {
        return OwnableInternal.owner();
    }

    /*===================
        AUTHORIZATION
    ===================*/

    function _checkCanUpdateERC6551AccountInitializer() internal view override {
        _checkPermission(Operations.ACCOUNT_INITIALIZER, msg.sender);
    }

    /// @dev Restrict Permissions write access to the `Operations.PERMISSIONS` permission
    function _checkCanUpdatePermissions() internal view override {
        _checkPermission(Operations.PERMISSIONS, msg.sender);
    }

    /// @dev Restrict Guards write access to the `Operations.GUARDS` permission
    function _checkCanUpdateGuards() internal view override {
        _checkPermission(Operations.GUARDS, msg.sender);
    }

    /// @dev Restrict calls via Execute to the `Operations.EXECUTE` permission
    function _checkCanExecuteCall() internal view override {
        _checkPermission(Operations.CALL, msg.sender);
    }

    /// @dev Restrict ERC-165 write access to the `Operations.INTERFACE` permission
    function _checkCanUpdateInterfaces() internal view override {
        _checkPermission(Operations.INTERFACE, msg.sender);
    }

    /// @dev Only the `owner` possesses Extensions write access
    function _checkCanUpdateExtensions() internal view override {
        // changes to core functionality must be restricted to owners to protect admins overthrowing
        _checkOwner();
    }

    /// @dev Only the `owner` possesses UUPS upgrade rights
    function _authorizeUpgrade(address) internal view override {
        // changes to core functionality must be restricted to owners to protect admins overthrowing
        _checkOwner();
    }
}
