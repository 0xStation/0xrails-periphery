// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./IDelayedRevealRenderer.sol";

contract DelayedRevealRenderer is IDelayedRevealRenderer, Ownable {
    using Strings for uint256;

    mapping(address => bool) public revealed;
    mapping(address => string) public baseURIs;

    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    function reveal(address token) external onlyOwner {
        require(msg.sender == Ownable(token).owner(), "NOT_OWNER");
        revealed[token] = true;
        emit Revealed(token);
    }

    function updateBaseURI(address token, string memory _baseURI) external onlyOwner {
        require(msg.sender == Ownable(token).owner(), "NOT_OWNER");
        baseURIs[token] = _baseURI;
        emit UpdatedBaseURI(token, _baseURI);
    }

    function tokenURI(address token, uint256 tokenId) external view returns (string memory) {
      bool isRevealed = revealed[token];
      string memory baseURI = baseURIs[token];

      if (!isRevealed) {
        return string(
            abi.encodePacked(
                baseURI,
                "pre.json"
            )
        );
      }
       return string(
          abi.encodePacked(
              baseURI,
              Strings.toString(tokenId),
              ".json"
          )
      );
    }
}
