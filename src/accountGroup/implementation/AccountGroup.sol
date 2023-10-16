// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC6551AccountGroupStorage} from "./ERC6551AccountGroupStorage.sol";
import {IERC6551AccountGroup} from "0xrails/lib/ERC6551AccountGroup/interface/IERC6551AccountGroup.sol";
import {IAccountGroup} from "../interface/IAccountGroup.sol";
import {AccountGroupLib} from "../lib/AccountGroupLib.sol";

abstract contract AccountGroup is IERC6551AccountGroup, IAccountGroup {
    function getAccountInitializer(address account) public view returns (address) {
        (,uint64 subgroupId,) = AccountGroupLib.accountParams();
        return ERC6551AccountGroupStorage.layout().initalizerOf[subgroupId];
    }
    
    function getAccountImplementation(address account) public view returns (address) {
        (,uint64 subgroupId,) = AccountGroupLib.accountParams();
        return ERC6551AccountGroupStorage.layout().accountOf[subgroupId];
    }

    function updateSubgroup(uint64 subgroupId, address accountImpl, address initializer) public {
        _checkCanUpdateSubgroup(subgroupId);
        ERC6551AccountGroupStorage layout = ERC6551AccountGroupStorage.layout();
        layout.initalizerOf[subgroupId] = initalizer;
        layout.accountOf[subgroupId] = accountImpl;
        emit SubgroupInitializationUpdated(subgroupId, accountImpl, initializer);
    }

    function _checkCanUpdateSubgroup(uint64 subgroupId) internal virtual;
}
