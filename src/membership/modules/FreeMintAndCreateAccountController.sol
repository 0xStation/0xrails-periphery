// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC6551Registry} from "erc6551/ERC6551Registry.sol";
import {IERC6551AccountInitializer} from "0xrails/lib/ERC6551AccountGroup/interface/IERC6551AccountInitializer.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
// module utils
import {PermitController} from "src/lib/module/PermitController.sol";
import {SetupController} from "src/lib/module/SetupController.sol";
import {ERC6551AccountController} from "src/lib/module/ERC6551AccountController.sol";

interface IERC721RailsV2 is IERC721Rails {
    function totalMinted() external view returns (uint256);
}

contract FreeMintAndCreateAccountController is PermitController, SetupController, ERC6551AccountController {
    constructor() PermitController() {}

    struct AccountConfig {
        address registry;
        address accountProxy;
        bytes32 salt;
        address accountImpl;
        bytes initData;
    }

    /// @dev Mint a single ERC721Rails token and deploy its tokenbound account
    function mintAndCreateAccount(address collection, address recipient, AccountConfig calldata accountConfig)
        external
        usePermits(_encodePermitContext(collection))
    {
        IERC721RailsV2(collection).mintTo(recipient, 1);
        // assumes that startTokenId = 1 -> true for our default ERC721Rails implementation
        // assumes that tokens are only minted in sequential order -> true for our default ERC721Rails implementation, but may change with the introduction of counterfactual tokenIds
        uint256 newTokenId = IERC721RailsV2(collection).totalMinted();
        address account = _createAccount(
            accountConfig.registry,
            accountConfig.accountProxy,
            accountConfig.salt,
            block.chainid,
            collection,
            newTokenId
        );
        _initializeAccount(account, accountConfig.accountImpl, accountConfig.initData);
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

    function requirePermits(bytes memory context) public view override returns (bool) {
        address collection = _decodePermitContext(context);
        return !IPermissions(collection).hasPermission(Operations.MINT_PERMIT, msg.sender);
    }

    function signerCanPermit(address signer, bytes memory context) public view override returns (bool) {
        address collection = _decodePermitContext(context);
        return IPermissions(collection).hasPermission(Operations.MINT_PERMIT, signer);
    }
}
