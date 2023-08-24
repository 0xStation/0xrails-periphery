// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SignatureChecker, ECDSA} from "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";

import {NonceBitMap} from "src/lib/NonceBitMap.sol";

abstract contract ModulePermit is NonceBitMap {
    struct Permit {
        address signer; // take signer as explicit argument to support smart contract signers with EIP1271
        address sender;
        uint48 expiration;
        uint256 nonce;
        bytes data;
        bytes signature;
    }

    /*============
        ERRORS
    ============*/

    error Reentrancy();
    error PermitSignerInvalid(address signer);
    error PermitExpired(uint48 expiration, uint48 current);
    error PermitSenderMismatch(address expected, address sender);
    error PermitInvalidSignature(address signer, bytes32 permitHash, bytes signature);
    error PermitCallFailed(bytes data);
    error PermitCallUnprotected();

    /*=============
        STORAGE
    =============*/

    // signatures
    bytes32 private constant GRANT_TYPE_HASH =
        keccak256("Permit(address sender,uint48 expiration,uint256 nonce,bytes data)");
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
    address private verifiedSigner = UNVERIFIED;
    uint256 private lock = UNLOCKED;

    constructor() {
        INITIAL_DOMAIN_SEPARATOR = _domainSeparator();
        INITIAL_CHAIN_ID = block.chainid;
    }

    /*====================
        CORE UTILITIES
    ====================*/

    /// @notice authenticate module functions for collections with permits and reentrancy protection
    modifier usePermits(bytes memory context) {
        address signer = verifiedSigner;
        // validate permits are required, signer is verified, and signer can permit
        if (requirePermits(context) && (signer == UNVERIFIED || !signerCanPermit(signer, context))) {
            revert PermitSignerInvalid(signer);
        }
        // reentrancy protection
        if (lock != UNLOCKED) revert Reentrancy();
        // lock
        lock = LOCKED;
        // function execution
        _;
        // unlock
        lock = UNLOCKED;
    }

    /// @notice authenticate permit and make a self-call
    /// @dev can only be used on functions that are protected with onlyPermited
    function callWithPermit(Permit calldata permit) external payable {
        if (permit.expiration < block.timestamp) revert PermitExpired(permit.expiration, uint48(block.timestamp));
        if (permit.sender != address(0) && permit.sender != msg.sender) {
            revert PermitSenderMismatch(permit.sender, msg.sender);
        }
        // use nonce, reverts if already used
        _useNonce(permit.signer, permit.nonce);
        // verify signer, reverts if invalid
        _verifySigner(permit);
        // set signer as verified state to be used in "real" call
        verifiedSigner = permit.signer;
        // make authenticated call
        Address.functionDelegateCall(address(this), permit.data);
        // reset verified signer
        verifiedSigner = UNVERIFIED;
    }

    /// @notice override to customize which signers are allowed
    function signerCanPermit(address, bytes memory) public view virtual returns (bool) {
        return false;
    }

    /// @notice override to support disabling permits
    function requirePermits(bytes memory) public view virtual returns (bool) {
        return true;
    }

    /*=====================
        PRIVATE HELPERS
    =====================*/

    /// @notice Verify the signer, signature, and data align and revert otherwise
    function _verifySigner(Permit memory permit) private view {
        // hash permit values
        bytes32 valuesHash = keccak256(
            abi.encode(
                GRANT_TYPE_HASH,
                permit.sender,
                permit.expiration,
                permit.nonce,
                // per EIP712 spec, need to hash variable length data to 32-bytes value first
                keccak256(permit.data)
            )
        );
        // hash domain with permit values
        bytes32 permitHash = ECDSA.toTypedDataHash(
            INITIAL_CHAIN_ID == block.chainid ? INITIAL_DOMAIN_SEPARATOR : _domainSeparator(), valuesHash
        );
        // verify signer, revert if invalid
        if (!SignatureChecker.isValidSignatureNow(permit.signer, permitHash, permit.signature)) {
            revert PermitInvalidSignature(permit.signer, permitHash, permit.signature);
        }
    }

    function _domainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_TYPE_HASH, NAME_HASH, VERSION_HASH, block.chainid, address(this)));
    }
}