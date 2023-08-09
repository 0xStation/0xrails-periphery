// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC721Mage} from "mage/cores/ERC721/interface/IERC721Mage.sol";
import {IPermissions} from "mage/access/permissions/interface/IPermissions.sol";
import {Operations} from "mage/lib/Operations.sol";

import {ModuleSetup} from "src/v2/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/v2/lib/module/ModuleGrant.sol";
import {ModuleFee} from "src/v2/lib/module/ModuleFee.sol";
import {PayoutAddressExtension} from "src/v2/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";

/// @title Station Network GasCoinPurchaseModuleV2 Contract
/// @author symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth
/// @dev Provides a modular contract to handle collections who wish for their membership mints to be
/// paid in the native currency of the chain this contract is deployed to

contract GasCoinPurchaseModule is ModuleSetup, ModuleGrant, ModuleFee {
    /*=============
        STORAGE
    =============*/

    /// @dev Mapping to show if a collection prevents or allows minting via signature grants, ie collection address => repealGrants
    mapping(address => bool) internal _repealGrants;
    /// @dev Mapping of collections to their mint's native currency price
    mapping(address => uint256) public prices;

    /*============
        EVENTS
    ============*/

    event SetUp(address indexed collection, uint256 price, bool indexed enforceGrants);

    /*============
        CONFIG
    ============*/

    /// @param _newOwner The owner of the ModuleFeeV2, an address managed by Station Network
    /// @param _feeManager The FeeManager's address
    constructor(address _newOwner, address _feeManager) ModuleGrant() ModuleFee(_newOwner, _feeManager) {}

    /// @dev Function to set up and configure a new collection's purchase prices
    /// @param collection The new collection to configure
    /// @param price The price in this chain's native currency for this collection's mints
    /// @param enforceGrants A boolean to represent whether this collection will repeal or support grant functionality
    function setUp(address collection, uint256 price, bool enforceGrants) external canSetUp(collection) {
        if (prices[collection] != price) {
            prices[collection] = price;
        }
        if (_repealGrants[collection] != !enforceGrants) {
            _repealGrants[collection] = !enforceGrants;
        }

        emit SetUp(collection, price, enforceGrants);
    }

    /*==========
        MINT
    ==========*/

    /// @dev Function to get a collection's mint price in native currency price
    function priceOf(address collection) public view returns (uint256 price) {
        price = prices[collection];
        require(price > 0, "NO_PRICE");
    }

    /// @dev Function to mint a single collection token to the caller, ie a user
    function mint(address collection) external payable returns (uint256 tokenId) {
        _batchMint(collection, msg.sender, 1);
    }

    /// @dev Function to mint a single collection token to a specified recipient
    function mintTo(address collection, address recipient) external payable returns (uint256 tokenId) {
        _batchMint(collection, recipient, 1);
    }

    /// @dev Function to mint collection tokens in batches to the caller, ie a user
    /// @notice returned tokenId range is inclusive
    function batchMint(address collection, uint256 quantity) external payable {
        _batchMint(collection, msg.sender, quantity);
    }

    /// @dev Function to mint collection tokens in batches to a specified recipient
    /// @notice returned tokenId range is inclusive
    function batchMintTo(address collection, address recipient, uint256 quantity) external payable {
        _batchMint(collection, recipient, quantity);
    }

    /*===============
        INTERNALS
    ===============*/

    /// @dev Internal function to which all external user + client facing batchMint functions are routed.
    /// @param collection The token collection to mint from
    /// @param recipient The recipient of successfully minted tokens
    /// @param quantity The quantity of tokens to mint
    /// @notice returned tokenId range is inclusive
    function _batchMint(address collection, address recipient, uint256 quantity)
        internal
        enableGrants(abi.encode(collection))
    {
        require(quantity > 0, "ZERO_QUANTITY");

        // reverts if collection has not been setUp()
        uint256 price = priceOf(collection);

        // take fee and register to ModuleFeeV2 storage
        _registerFeeBatch(collection, address(0x0), recipient, quantity, price);

        // send payment
        address payoutAddress = PayoutAddressExtension(collection).payoutAddress();
        (bool success,) = payoutAddress.call{value: price * quantity}("");
        require(success, "PAYMENT_FAIL");

        IERC721Mage(collection).mintTo(recipient, quantity);
    }

    /*============
        GRANTS
    ============*/

    function validateGrantSigner(bool grantInProgress, address signer, bytes memory callContext)
        public
        view
        override
        returns (bool)
    {
        address collection = abi.decode(callContext, (address));
        return (grantInProgress && IPermissions(collection).hasPermission(Operations.MINT_PERMIT, signer))
            || (!grantsEnforced(collection));
    }

    function grantsEnforced(address collection) public view returns (bool) {
        return !_repealGrants[collection];
    }
}
