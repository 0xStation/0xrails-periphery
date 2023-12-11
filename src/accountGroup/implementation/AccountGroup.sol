// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {IERC6551AccountGroup} from "0xrails/lib/ERC6551AccountGroup/interface/IERC6551AccountGroup.sol";
import {Ownable, Ownable} from "0xrails/access/ownable/Ownable.sol";
import {Access} from "0xrails/access/Access.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";

import {AccountGroupStorage} from "./AccountGroupStorage.sol";
import {IAccountGroup} from "../interface/IAccountGroup.sol";
import {AccountGroupLib} from "../lib/AccountGroupLib.sol";

contract AccountGroup is IERC6551AccountGroup, IAccountGroup, UUPSUpgradeable, Access, Initializable, Ownable {
    /*====================
        INITIALIZATION
    ====================*/

    function initialize(address owner_) external initializer {
        _transferOwnership(owner_);
    }

    /*===========
        VIEWS
    ===========*/

    function getAccountInitializer(address account) external view returns (address) {
        // fetch subgroupId from account's contract bytecode
        AccountGroupLib.AccountParams memory params = AccountGroupLib.accountParams(account);
        // query namespaced storage for initializer associated with `subgroupId`
        AccountGroupStorage.Layout storage layout = AccountGroupStorage.layout();
        address initializer = layout.initializerOf[params.subgroupId];

        // handle unset initializer using default
        if (initializer == address(0)) {
            initializer = layout.defaultInitializer;
        }
        return initializer;
    }

    function getDefaultAccountInitializer() external view returns (address) {
        return AccountGroupStorage.layout().defaultInitializer;
    }

    function getDefaultAccountImplementation() external view returns (address defaultImpl) {
        // query namespaced storage for the default implementation
        AccountGroupStorage.Layout storage layout = AccountGroupStorage.layout();
        defaultImpl = layout.defaultAccountImplementation;
    }

    /// @inheritdoc IERC6551AccountGroup
    function checkValidAccountUpgrade(address sender, address account, address implementation) external view {
        if (
            implementation == AccountGroupStorage.layout().defaultAccountImplementation
                && (sender == Access(account).owner() || hasPermission(Operations.ADMIN, sender))
        ) {
            return;
        }

        revert UpgradeRestricted(sender, account, implementation);
    }

    /*=============
        SETTERS
    =============*/

    function setDefaultAccountInitializer(address initializer) external onlyOwner {
        AccountGroupStorage.layout().defaultInitializer = initializer;
        emit DefaultInitializerUpdated(initializer);
    }

    function setAccountInitializer(uint64 subgroupId, address initializer) public {
        _checkCanUpdateSubgroup(subgroupId);
        AccountGroupStorage.layout().initializerOf[subgroupId] = initializer;
        emit SubgroupInitializerUpdated(subgroupId, initializer);
    }

    /// @inheritdoc IAccountGroup
    function setDefaultAccountImplementation(address implementation) external onlyOwner {
        AccountGroupStorage.layout().defaultAccountImplementation = implementation;
        emit DefaultAccountImplementationUpdated(implementation);
    }

    /*===================
        AUTHORIZATION
    ===================*/

    /// @dev Owner address is implemented using the `Ownable` contract's function
    function owner() public view override(Access, Ownable) returns (address) {
        return Ownable.owner();
    }

    function _checkCanUpdateSubgroup(uint64) internal view {
        _checkPermission(Operations.ADMIN, _msgSender());
    }

    /// @dev Restrict Permissions write access to the `Operations.PERMISSIONS` permission
    function _checkCanUpdatePermissions() internal view override {
        _checkPermission(Operations.PERMISSIONS, _msgSender());
    }

    /// @dev Only the `owner` possesses UUPS upgrade rights
    function _authorizeUpgrade(address) internal view override {
        // changes to core functionality must be restricted to owners to protect admins overthrowing
        _checkOwner();
    }
}
