// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Permissions} from "src/lib/Permissions.sol";
import {NonceBitMap} from "src/lib/NonceBitMap.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

abstract contract ModuleGrant is NonceBitMap {
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
    bytes32 private constant GRANT_TYPE_HASH =
        keccak256("Grant(address sender,uint48 expiration,uint256 nonce,bytes data)");
    bytes32 private constant DOMAIN_TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant NAME_HASH = keccak256("GroupOS");
    bytes32 private constant VERSION_HASH = keccak256("0.0.1");
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    uint256 internal immutable INITIAL_CHAIN_ID;

    // authentication handoff
    address private constant UNVERIFIED = address(1);
    uint256 private constant UNLOCKED = 1;
    uint256 private constant LOCKED = 2;
    address private grantSigner = UNVERIFIED;
    uint256 private lock = UNLOCKED;

    constructor() {
        INITIAL_DOMAIN_SEPARATOR = _domainSeparator();
        INITIAL_CHAIN_ID = block.chainid;
    }

    /*============
        ERRORS
    ============*/

    error InvalidGrantSigner(address signer);
    error Reentrancy();
    error GrantExpired(uint48 expiration, uint48 current);
    error GrantSenderMismatch(address argument, address sender);
    error GrantCallFailed(bytes data);
    error GrantCallUnprotected();

    /*====================
        CORE UTILITIES
    ====================*/

    /// @notice authenticate module functions for collections with grants and reentrancy protection
    modifier enableGrants(bytes memory callContext) {
        address signer = grantSigner;
        bool grantInProgress = signer != UNVERIFIED;
        // validate signer can issue grants
        if (!validateGrantSigner(grantInProgress, signer, callContext)) revert InvalidGrantSigner(signer);
        // reentrancy protection
        if (lock != UNLOCKED) revert Reentrancy();
        // lock
        lock = LOCKED;
        // function execution
        _;
        // unlock
        lock = UNLOCKED;
    }

    /// @notice support calling a function with a grant as the sole permitted sender
    function callWithGrant(
        address sender,
        uint48 expiration,
        uint256 nonce,
        bytes calldata data,
        bytes calldata signature
    ) external payable {
        _callWithGrant(Grant(sender, expiration, nonce, data, signature));
    }

    /// @notice virtual to enable modules to customize when signers are allowed
    function validateGrantSigner(bool, address, bytes memory) public view virtual returns (bool) {
        return false; // should override implementation
    }

    /*=====================
        PRIVATE HELPERS
    =====================*/

    /// @notice authenticate grant and make a self-call
    /// @dev can only be used on functions that are protected with onlyGranted
    function _callWithGrant(Grant memory grant) private {
        if (grant.expiration < block.timestamp) revert GrantExpired(grant.expiration, uint48(block.timestamp));
        if (grant.sender != address(0) && grant.sender != msg.sender) {
            revert GrantSenderMismatch(grant.sender, msg.sender);
        }
        // recover signer from grant
        grantSigner = _recoverSigner(grant);
        // use nonce
        _useNonce(grantSigner, grant.nonce);
        // make authenticated call
        (bool success, bytes memory data) = address(this).delegatecall(grant.data);
        if (!success) revert GrantCallFailed(data);
        // reset grant signer
        grantSigner = UNVERIFIED;
    }

    /// @notice Mint tokens using a signature from a permitted minting address
    function _recoverSigner(Grant memory grant) private view returns (address signer) {
        // hash grant values
        bytes32 valuesHash = keccak256(
            abi.encode(
                GRANT_TYPE_HASH,
                grant.sender,
                grant.expiration,
                grant.nonce,
                // per EIP712 spec, need to hash variable length data to 32-bytes value first
                keccak256(grant.data)
            )
        );
        // hash domain with grant values
        bytes32 grantHash = ECDSA.toTypedDataHash(
            INITIAL_CHAIN_ID == block.chainid ? INITIAL_DOMAIN_SEPARATOR : _domainSeparator(), valuesHash
        );
        // recover signer
        signer = ECDSA.recover(grantHash, grant.signature);
    }

    function _domainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_TYPE_HASH, NAME_HASH, VERSION_HASH, block.chainid, address(this)));
    }
}
