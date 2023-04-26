// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./IRenderer.sol";

contract Renderer is IRenderer, Ownable {
    using Strings for uint256;

    string public baseURI;

    constructor(address _owner, string memory _baseURI) {
        _transferOwnership(_owner);
        baseURI = _baseURI;
    }

    function updateBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit UpdatedBaseURI(_baseURI);
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return string(
            abi.encodePacked(
                baseURI,
                "?contractAddress=",
                Strings.toHexString(uint160(msg.sender), 20),
                "&tokenId=",
                Strings.toString(tokenId)
            )
        );
    }
}
