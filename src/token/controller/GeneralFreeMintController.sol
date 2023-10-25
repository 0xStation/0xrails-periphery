// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20Rails} from "0xrails/cores/ERC20/interface/IERC20Rails.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import {IERC1155Rails} from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {PermitController} from "src/lib/module/PermitController.sol";
import {SetupController} from "src/lib/module/SetupController.sol";
import {ContractMetadata} from "src/lib/ContractMetadata.sol";

/// @title Station FreeMintController Contract
/// @author frog (@0xmcg), 👦🏻👦🏻.eth
/// @dev Mint tokens entirely for free with signature-based authentication
/// @dev Supports all three 0xRails token standard implementations: ERC20, ERC721, ERC1155
/// @notice As this controller is entirely fee-less, it does not make use of the FeeManager,
/// which enforces a baseline default mint fee
contract GeneralFreeMintController is PermitController, SetupController, ContractMetadata {

    /*=============
        STORAGE
    =============*/

    /// @dev collection => permits disabled, permits are enabled by default
    mapping(address => bool) internal _disablePermits;

    /*============
        EVENTS
    ============*/

    /// @dev Events share names but differ in parameters to differentiate them between controllers
    event SetUp(address indexed collection, bool indexed enablePermits);

    /*============
        CONFIG
    ============*/

    /// @param _metadataRouter The GroupOS MetadataRouter's address
    constructor(address _metadataRouter) 
        PermitController() 
        ContractMetadata(_metadataRouter) {}

    /// @dev Function to set up and configure a new collection's purchase prices
    /// @param collection The new collection to configure
    /// @param enablePermits A boolean to represent whether this collection will repeal or support grant functionality
    function setUpPermits(address collection, bool enablePermits) public canSetUp(collection) {
        if (_disablePermits[collection] != !enablePermits) {
            _disablePermits[collection] = !enablePermits;
        }
        emit SetUp(collection, enablePermits);
    }
    
    /// @dev convenience function for setting up when creating collections, relies on auth done in public setUp
    function setUpPermits(bool enablePermits) external {
        setUpPermits(msg.sender, enablePermits);
    }

    /*==========
        MINT
    ==========*/

    /// @dev Function to mint ERC20 collection tokens to a specified recipient
    function mintToERC20(address collection, address recipient, uint256 amount) external payable usePermits(_encodePermitContext(collection)) {
        require(amount > 0, "ZERO_AMOUNT");
        IERC20Rails(collection).mintTo(recipient, amount);
    }

    /// @dev Function to mint ERC721 collection tokens to a specified recipient
    function mintToERC721(address collection, address recipient, uint256 amount) external payable usePermits(_encodePermitContext(collection)) {
        require(amount > 0, "ZERO_AMOUNT");
        IERC721Rails(collection).mintTo(recipient, amount);
    }

    /// @dev Function to mint ERC20 collection tokens to a specified recipient
    function mintToERC1155(address collection, address recipient, uint256 tokenId, uint256 amount) external payable usePermits(_encodePermitContext(collection)) {
        require(amount > 0, "ZERO_AMOUNT");
        IERC1155Rails(collection).mintTo(recipient, tokenId, amount);
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

    /*==============
        OVERRIDE
    ==============*/

    function _contractRoute() internal pure override returns (string memory route) {
        return "module";
    }
}
