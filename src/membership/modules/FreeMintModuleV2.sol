// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFeeV2} from "src/lib/module/ModuleFeeV2.sol";

/// @title Station Network FreeMintModuleV2 Contract
/// @author symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth
/// @dev Provides a modular contract to handle collections who wish for their membership mints to be 
/// free of charge, save for Station Network's base fee

contract FreeMintModuleV2 is ModuleSetup, ModuleGrant, ModuleFeeV2 {
    
    /*=============
        STORAGE
    =============*/

    /// @dev Mapping to show if a collection prevents or allows minting via signature grants, ie collection address => repealGrants
    mapping(address => bool) internal _repealGrants;

    /*============
        EVENTS
    ============*/

    event SetUp(address indexed collection, bool indexed enforceGrants);
    event Mint(address indexed collection, address indexed recipient, uint256 fee);
    event Purchase(
        address indexed collection,
        address indexed recipient,
        address indexed paymentCoin,
        uint256 unitPrice,
        uint256 unitFee,
        uint256 units
    );

    /*============
        CONFIG
    ============*/

    /// @param _newOwner The owner of the ModuleFeeV2, an address managed by Station Network
    /// @param _feeManager The FeeManager's address
    constructor(address _newOwner, address _feeManager) ModuleGrant() ModuleFeeV2(_newOwner, _feeManager) {}

    /// @dev Function to set up and configure a new collection
    /// @param collection The new collection to configure
    /// @param enforceGrants A boolean to represent whether this collection will repeal or support grant functionality 
    function setUp(address collection, bool enforceGrants) external canSetUp(collection) {
        if (_repealGrants[collection] != !enforceGrants) {
            _repealGrants[collection] = !enforceGrants;
        }
        emit SetUp(collection, enforceGrants);
    }

    /*==========
        MINT
    ==========*/

    /// @dev Function to mint a single collection token to the caller, ie a user
    function mint(address collection) external payable returns (uint256 tokenId) {
        tokenId = _mint(collection, msg.sender);
    }

    /// @dev Function to mint a single collection token to a specified recipient
    function mintTo(address collection, address recipient) external payable returns (uint256 tokenId) {
        tokenId = _mint(collection, recipient);
    }

    /// @dev Function to mint collection tokens in batches to the caller, ie a user
    /// @notice returned tokenId range is inclusive
    function batchMint(address collection, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, msg.sender, amount);
    }

    /// @dev Function to mint collection tokens in batches to a specified recipient
    /// @notice returned tokenId range is inclusive
    function batchMintTo(address collection, address recipient, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, recipient, amount);
    }

    /*===============
        INTERNALS
    ===============*/

    /// @dev Internal function to which all external user + client facing single mint functions are routed.
    /// @param collection The token collection to mint from
    /// @param recipient The recipient of successfully minted tokens
    function _mint(address collection, address recipient)
        internal
        enableGrants(abi.encode(collection))
        returns (uint256 tokenId)
    {
        // reverts on invalid fee
        uint256 paidFee = _registerFee(collection, address(0x0), recipient, 0);
        tokenId = IMembership(collection).mintTo(recipient);
        emit Mint(collection, recipient, paidFee);
    }

    /// @dev Internal function to which all external user + client facing batchMint functions are routed.
    /// @param collection The token collection to mint from
    /// @param recipient The recipient of successfully minted tokens
    /// @param amount The amount of tokens to mint  
    function _batchMint(address collection, address recipient, uint256 amount)
        internal
        enableGrants(abi.encode(collection))
        returns (uint256 startTokenId, uint256 endTokenId)
        {
            require(amount > 0, "ZERO_AMOUNT");

            // take baseFee (variableFee == 0 when price == 0)
            uint256 paidFee = _registerFeeBatch(
                collection,
                address(0x0),
                recipient,
                amount,
                0
            );

            // perform mints
            for (uint256 i; i < amount; i++) {
                // mint token
                uint256 tokenId = IMembership(collection).mintTo(recipient);
                // prevent unsuccessful mint
                require(tokenId > 0, "MINT_FAILED");
                // set startTokenId on first mint
                if (startTokenId == 0) {
                    startTokenId = tokenId;
                }
            }

            emit Purchase(collection, recipient, address(0x0), 0, paidFee / amount, amount);

            return (startTokenId, startTokenId + amount - 1); // purely inclusive set
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
        return (grantInProgress && Permissions(collection).hasPermission(signer, Permissions.Operation.GRANT))
            || (!grantsEnforced(collection));
    }

    function grantsEnforced(address collection) public view returns (bool) {
        return !_repealGrants[collection];
    }
}
