// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFee} from "src/lib/module/ModuleFee.sol";

contract EthPurchaseModuleV2 is ModuleGrant, ModuleFee, ModuleSetup {
    /*=============
        STORAGE
    =============*/

    // TODO: pack collection config storage to one slot
    mapping(address => bool) internal _repealGrants;
    mapping(address => uint256) public prices;

    /*============
        EVENTS
    ============*/

    event SetUp(address indexed collection, uint256 price, bool indexed enforceGrants);
    event Purchase(address indexed collection, address indexed buyer, uint256 price, uint256 fee);

    /*============
        CONFIG
    ============*/

    constructor(address newOwner, uint256 newFee) ModuleGrant() ModuleFee(newOwner, newFee) {}

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

    function _mint(address collection, address recipient)
        internal
        enableGrants(abi.encode(collection))
        returns (uint256 tokenId)
    {
        uint256 price = priceOf(collection);
        uint256 paidFee = _registerFee(price);

        // send payment
        address paymentCollector = Membership(collection).paymentCollector();
        (bool success,) = paymentCollector.call{value: price}("");
        require(success, "PAYMENT_FAIL");

        // TODO: should we check that balance after - before = amount minted?
        tokenId = IMembership(collection).mintTo(recipient);
        emit Purchase(collection, recipient, price, paidFee);
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
