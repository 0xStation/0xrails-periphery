// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC6551Registry} from "erc6551/ERC6551Registry.sol";
import {IERC6551AccountInitializer} from "0xrails/lib/ERC6551AccountGroup/interface/IERC6551AccountInitializer.sol";

abstract contract ERC6551AccountController {
    function _createAccount(
        address registry,
        address accountProxy,
        bytes32 salt,
        uint256 chainId,
        address collection,
        uint256 tokenId
    ) internal returns (address account) {
        account = IERC6551Registry(registry).createAccount(accountProxy, salt, chainId, collection, tokenId);
    }

    function _initializeAccount(address account, address accountImpl, bytes calldata initData) internal {
        IERC6551AccountInitializer(account).initializeAccount(accountImpl, initData);
    }
}
