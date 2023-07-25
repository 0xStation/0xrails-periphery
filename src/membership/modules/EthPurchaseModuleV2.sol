// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFeeV2} from "src/lib/module/ModuleFeeV2.sol";

contract EthPurchaseModuleV2 is ModuleGrant, ModuleFeeV2, ModuleSetup {

    /*=============
        STORAGE
    =============*/

    mapping(address => bool) internal _repealGrants;
    mapping(address => uint256) public prices;

    /*============
        EVENTS
    ============*/

    event SetUp(address indexed collection, uint256 price, bool indexed enforceGrants);
    event Purchase(address indexed collection, address indexed buyer, uint256 price, uint256 fee);
    event BatchPurchase(
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

    constructor(address _newOwner, address _feeManager) ModuleGrant() ModuleFeeV2(_newOwner, _feeManager) {}

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

    function priceOf(address collection) public view returns (uint256 price) {
        price = prices[collection];
        require(price > 0, "NO_PRICE");
    }

    function mint(address collection) external payable returns (uint256 tokenId) {
        tokenId = _mint(collection, msg.sender);
    }

    function mintTo(address collection, address recipient) external payable returns (uint256 tokenId) {
        tokenId = _mint(collection, recipient);
    }

    /// @notice returned tokenId range is inclusive
    function batchMint(address collection, uint256 amount)
        external
        payable
        returns (uint256 startTokenId, uint256 endTokenId)
    {
        return _batchMint(collection, msg.sender, amount);
    }

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

    function _mint(address collection, address recipient)
        internal
        enableGrants(abi.encode(collection))
        returns (uint256 tokenId)
    {
        // reverts if collection has not been setUp()
        uint256 price = priceOf(collection);

        // get total invoice incl fees and register to ModuleFeeV2 storage
        uint256 paidFee = _registerFee(
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
        emit Purchase(collection, recipient, price, paidFee);
    }

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
        uint256 paidFee = _registerFeeBatch(
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

        emit BatchPurchase(collection, recipient, address(0x0), price, paidFee / amount, amount);

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
