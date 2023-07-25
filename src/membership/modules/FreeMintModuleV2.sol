// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFeeV2} from "src/lib/module/ModuleFeeV2.sol";

contract FreeMintModuleV2 is ModuleSetup, ModuleGrant, ModuleFeeV2 {
    
    /*=============
        STORAGE
    =============*/

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

    constructor(address _newOwner, address _feeManager) ModuleGrant() ModuleFeeV2(_newOwner, _feeManager) {}

    function setUp(address collection, bool enforceGrants) external canSetUp(collection) {
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
        // reverts on invalid fee
        uint256 paidFee = _registerFee(collection, address(0x0), recipient, 0);
        tokenId = IMembership(collection).mintTo(recipient);
        emit Mint(collection, recipient, paidFee);
    }

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
