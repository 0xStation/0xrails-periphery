// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {IERC6551AccountGroup} from "0xrails/lib/ERC6551AccountGroup/interface/IERC6551AccountGroup.sol";
import {Ownable, OwnableInternal} from "0xrails/access/ownable/Ownable.sol";
import {Access} from "0xrails/access/Access.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";

import {AccountGroupStorage} from "./AccountGroupStorage.sol";
import {IAccountGroup} from "../interface/IAccountGroup.sol";
import {AccountGroupLib} from "../lib/AccountGroupLib.sol";

abstract contract AccountGroup is IERC6551AccountGroup, IAccountGroup, UUPSUpgradeable, Access, Initializable, Ownable {

    // initialization

    function initialize(address owner_) external initializer {
        _transferOwnership(owner_);
    }

    /// @dev Owner address is implemented using the `OwnableInternal` contract's function
    function owner() public view override(Access, OwnableInternal) returns (address) {
        return OwnableInternal.owner();
    }

    // subgroups

    function getAccountInitializer(address) public view returns (address) {
        (,uint64 subgroupId,) = AccountGroupLib.accountParams();
        return AccountGroupStorage.layout().initializerOf[subgroupId];
    }

    function setAccountInitializer(uint64 subgroupId, address initializer) public {
        _checkCanUpdateSubgroup(subgroupId);
        AccountGroupStorage.layout().initializerOf[subgroupId] = initializer;
        emit SubgroupInitializerUpdated(subgroupId, initializer);
    }

    // auth

    function _checkCanUpdateSubgroup(uint64) internal view {
        _checkPermission(Operations.ADMIN, msg.sender);
    }

    /// @dev Restrict Permissions write access to the `Operations.PERMISSIONS` permission
    function _checkCanUpdatePermissions() internal view override {
        _checkPermission(Operations.PERMISSIONS, msg.sender);
    }

    /// @dev Only the `owner` possesses UUPS upgrade rights
    function _authorizeUpgrade(address) internal view override {
        // changes to core functionality must be restricted to owners to protect admins overthrowing
        _checkOwner();
    }
}
