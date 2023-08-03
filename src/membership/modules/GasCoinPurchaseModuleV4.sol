// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFeeV2} from "src/lib/module/ModuleFeeV2.sol";

/// @title Station Network GasCoinPurchaseModuleV2 Contract
/// @author symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth
/// @dev Provides a modular contract to handle collections who wish for their membership mints to be 
/// paid in the native currency of the chain this contract is deployed to

contract GasCoinPurchaseModuleV4 is ModuleGrant, ModuleFeeV2, ModuleSetup {

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
    constructor(address _newOwner, address _feeManager) ModuleGrant() ModuleFeeV2(_newOwner, _feeManager) {}

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
        // reverts if collection has not been setUp()
        uint256 price = priceOf(collection);

        // get total invoice incl fees and register to ModuleFeeV2 storage
        _registerFee(
            collection, 
            address(0x0), 
            recipient, 
            price
        );

        // send payment
        address paymentCollector = Membership(collection).paymentCollector();
        (bool success,) = paymentCollector.call{ value: price }("");
        require(success, "PAYMENT_FAIL");

        tokenId = IMembership(collection).mintTo(recipient);
    }

    /// @dev Internal function to which all external user + client facing batchMint functions are routed.
    /// @param collection The token collection to mint from
    /// @param recipient The recipient of successfully minted tokens
    /// @param amount The amount of tokens to mint  
    /// @notice returned tokenId range is inclusive
    function _batchMint(address collection, address recipient, uint256 amount)
        internal
        enableGrants(abi.encode(collection))
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        require(amount > 0, "ZERO_AMOUNT");

        // reverts if collection has not been setUp()
        uint256 price = priceOf(collection);

        // take fee and register to ModuleFeeV2 storage
        _registerFeeBatch(
            collection,
            address(0x0),
            recipient,
            amount,
            price
        );

        // send payment
        address paymentCollector = Membership(collection).paymentCollector();
        (bool success,) = paymentCollector.call{ value: price * amount }("");
        require(success, "PAYMENT_FAIL");

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
