// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFee} from "src/lib/module/ModuleFee.sol";

contract FreeMintModule is ModuleSetup, ModuleGrant, ModuleFee {
    /*=============
        STORAGE
    =============*/

    mapping(address => bool) internal _repealGrants;

    /*============
        EVENTS
    ============*/

    event SetUp(address indexed collection, bool indexed enforceGrants);
    event Mint(address indexed collection, address indexed recipient, uint256 fee);

    /*============
        CONFIG
    ============*/

    constructor(address newOwner, uint256 newFee) ModuleGrant() ModuleFee(newOwner, newFee) {}

    function setUp(bool enforceGrants) external {
        _setUp(msg.sender, enforceGrants);
    }

    function setUp(address collection, bool enforceGrants) external {
        _canSetUp(collection, msg.sender);
        _setUp(collection, enforceGrants);
    }

    function _setUp(address collection, bool enforceGrants) internal {
        if (_repealGrants[collection] != !enforceGrants) {
            _repealGrants[collection] = !enforceGrants;
        }
        emit SetUp(collection, enforceGrants);
    }

    /*==========
        MINT
    ==========*/

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
        uint256 paidFee = _registerFee(); // reverts on invalid fee
        (tokenId) = IMembership(collection).mintTo(recipient);
        require(tokenId > 0, "MINT_FAILED");
        emit Mint(collection, recipient, paidFee);
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
        return (!grantInProgress && !grantsEnforced(collection))
            || (grantInProgress && Permissions(collection).hasPermission(signer, Permissions.Operation.GRANT));
    }

    function grantsEnforced(address collection) public view returns (bool) {
        return !_repealGrants[collection];
    }
}
