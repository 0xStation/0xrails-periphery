// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.16;

/// @notice Utility for making address-keyed nonce bitmaps for parallelized signature replay protection
abstract contract NonceBitMap {
    /*=============
        STORAGE
    =============*/

    // account => bitmap for tracking nonces, bitmaps used for gas efficient parallel processing
    mapping(address => mapping(uint256 => uint256)) internal _usedNonces;

    /*============
        EVENTS
    ============*/

    event UseNonce(address indexed account, uint256 indexed nonce);

    /*==================
        VERIFICATION
    ==================*/

    function isNonceUsed(address account, uint256 nonce) public view returns (bool) {
        (, uint256 word, uint256 mask) = _split(account, nonce);
        return word & mask != 0;
    }

    function _useNonce(address account, uint256 nonce) internal {
        (uint256 wordId, uint256 word, uint256 mask) = _split(account, nonce);
        require(word & mask == 0, "NONCE_USED");
        _usedNonces[account][wordId] = word | mask;
        emit UseNonce(account, nonce);
    }

    function _split(address account, uint256 nonce) private view returns (uint256 wordId, uint256 word, uint256 mask) {
        wordId = nonce >> 8;
        mask = 1 << (nonce & 0xff);
        word = _usedNonces[account][wordId];
    }
}
