// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./IRenderer.sol";

contract DelayedRevealRenderer is IRenderer, Ownable {
    using Strings for uint256;

    bool public revealed;
    string public baseURI;
    string public preRevealedContentHash;
    mapping (uint256 => string) private contentHashes;

    constructor(address _owner, string memory _baseURI, string memory _prePrevealedContentHash) {
        _transferOwnership(_owner);
        baseURI = _baseURI;
        preRevealedContentHash = _prePrevealedContentHash;
        revealed = false;
    }

    function reveal() external onlyOwner {
        revealed = true;
    }

    function updateBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit UpdatedBaseURI(_baseURI);
    }

    function setContentHash(uint256 tokenId, string memory contentHash) external onlyOwner {
        contentHashes[tokenId] = contentHash;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
      if (!revealed) {
        return string(
            abi.encodePacked(
                baseURI,
                preRevealedContentHash
            )
        );
      }
       return string(
          abi.encodePacked(
              baseURI,
              contentHashes[tokenId]
          )
      );
    }
}
