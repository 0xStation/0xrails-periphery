// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SignatureChecker} from "openzeppelin-contracts/utils/cryptography/SignatureChecker.sol";

import {AccountInitializer} from "./AccountInitializer.sol";
import {ERC6551AccountGroupLib} from "./lib/ERC6551AccountGroupLib.sol";
import {IPermissions} from "0xrails/access/permissions/interface/IPermissions.sol";
import {Operations} from "0xrails/lib/Operations.sol";

contract SignatureInitializer is AccountInitializer {
    error AlreadyInitialized();
    error InvalidInitilizationSignature();
    error Unauthorized();

    // signatures
    address immutable initializer;
    bytes32 private constant INITIALIZATION_TYPE_HASH =
        keccak256("Initialization(address account,address implementation,bytes data)");
    bytes32 private constant DOMAIN_TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant NAME_HASH = keccak256("GroupOS");
    bytes32 private constant VERSION_HASH = keccak256("0.0.1");
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    uint256 internal immutable INITIAL_CHAIN_ID;

    constructor() {
        initializer = address(this);
        INITIAL_DOMAIN_SEPARATOR = _domainSeparator();
        INITIAL_CHAIN_ID = block.chainid;
    }

    /// @notice Verify the signer, signature, and data align and revert otherwise
    function _authenticateInitialization(address implementation, bytes memory initData) internal view returns (bytes) {
        (address signer, bytes signature, bytes accountData) = abi.decode(initData, (address, bytes, bytes));

        // 1. Generate hash for initialization
        bytes32 valuesHash = keccak256(
            abi.encode(
                INITIALIZATION_TYPE_HASH,
                address(this), // assuming being delegatecall'ed by ERC6551 Account
                implementation,
                // per EIP712 spec, need to hash variable length data to 32-bytes value first
                keccak256(accountData)
            )
        );
        bytes32 msgHash = ECDSA.toTypedDataHash(
            INITIAL_CHAIN_ID == block.chainid ? INITIAL_DOMAIN_SEPARATOR : _domainSeparator(), valuesHash
        );

        // verify signature, revert if invalid
        if (!SignatureChecker.isValidSignatureNow(signer, msgHash, signature)) {
            revert InvalidInitilizationSignature();
        }

        // verify signer, revert if invalid
        (address accountGroup,,) = ERC6551AccountGroupLib.accountParams();
        if (!IPermissions(accountGroup).hasPermission(Operations.INITIALIZE_ACCOUNT, signer)) {
            revert Unauthorized();
        }

        return accountData;
    }

    function _domainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                DOMAIN_TYPE_HASH,
                NAME_HASH,
                VERSION_HASH,
                block.chainid,
                initializer // initializer is the verifying contract, not the Account
            )
        );
    }
}
