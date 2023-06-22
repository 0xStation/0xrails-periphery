// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions} from "src/lib/Permissions.sol";
import {NonceBitmap} from "src/lib/NonceBitmap.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

abstract contract ModuleGrant is NonceBitmap {
    struct Grant {
        address sender;
        uint48 expiration;
        uint256 nonce;
        bytes data;
        bytes signature;
    }

    /*=============
        STORAGE
    =============*/

    // signatures

    // keccak("Grant(address sender,uint48 expiration,uint256 nonce,bytes data)")
    bytes32 private constant GRANT_TYPEHASH = 0x19e3b6d0efd75ce8f4d43297a4bfdfcff5ced60bb9955c042552dc6546dfc63d;
    // keccak("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
    bytes32 private constant DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    bytes32 private constant NAME = "GroupOS";
    bytes32 private constant VERSION = "0.0.1";
    bytes32 internal immutable INITIAL_ACTION_DOMAIN_SEPARATOR;
    uint256 internal immutable INITIAL_CHAIN_ID;

    // authentication handoff

    address private constant UNVERIFIED = address(1);
    uint256 private constant UNLOCKED = 1;
    uint256 private constant LOCKED = 2;
    address private grantSigner = UNVERIFIED;
    uint256 private lock = UNLOCKED;

    constructor() {
        INITIAL_ACTION_DOMAIN_SEPARATOR = _getActionDomainSeparator();
        INITIAL_CHAIN_ID = block.chainid;
    }

    /*====================
        CORE UTILITIES
    ====================*/

    /// @notice authenticate module functions for collections with grants and reentrancy protection
    modifier onlyGranted(address collection) {
        // grant authentication
        address signer = grantSigner;
        require(
            // grants unenforced or
            !grantsEnforced(collection)
            // signer has permission to grant
            // signer checked as UNVERIFIED first for gas opt and to prevent subtle attack vector of permitting address(1) side effects
            || (signer != UNVERIFIED && Permissions(collection).hasPermission(signer, Permissions.Operation.GRANT)),
            "UNAUTHORIZED"
        );
        // reentrancy protection
        require(lock == UNLOCKED, "REENTRANCY");
        // lock
        lock = LOCKED;
        // function execution
        _;
        // unlock
        lock = UNLOCKED;
    }

    /// @notice support calling a function with a grant
    function callWithGrant(Grant calldata grant) external {
        // extract signer from grant
        grantSigner = _recoverSigner(grant);
        // make authenticated call
        (bool success,) = address(this).delegatecall(grant.data);
        require(success, "FAILED");
        // reset signer
        grantSigner = UNVERIFIED;
    }

    /// @notice virtual to enable modules to customize storage packing of grant ignoring status
    function grantsEnforced(address collection) public view virtual returns (bool) {
        return true; // should override implementation
    }

    /*=====================
        PRIVATE HELPERS
    =====================*/

    /// @notice Mint tokens using a signature from a permitted minting address
    function _recoverSigner(Grant calldata grant) private returns (address signer) {
        // require empty sender or matches msg.sender
        require(grant.sender == address(0) || grant.sender == msg.sender, "INVALID_SENDER");
        // hash grant
        bytes32 hash = _hashGrant(grant);
        // recover signer
        signer = ECDSA.recover(hash, grant.signature);
        // use nonce
        _useNonce(signer, grant.nonce);
    }

    function _hashGrant(Grant calldata grant) private returns (bytes32 grantHash) {
        bytes32 valuesHash =
            keccak256(abi.encode(GRANT_TYPEHASH, grant.sender, grant.expiration, grant.nonce, grant.data));

        grantHash = ECDSA.toTypedDataHash(
            INITIAL_CHAIN_ID == block.chainid ? INITIAL_ACTION_DOMAIN_SEPARATOR : _getActionDomainSeparator(),
            valuesHash
        );
    }

    function _getActionDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccack256(abi.encode(NAME)),
                keccak256(abi.encode(VERSION_HASH)),
                block.chainid,
                address(this)
            )
        );
    }
}