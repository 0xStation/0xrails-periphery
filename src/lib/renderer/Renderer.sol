// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract Renderer {
    using Strings for uint256;

    string public baseURI;

    constructor(string memory _baseURI) {
        baseURI = _baseURI;
    }

    function updateBaseURI(string memory uri) external {
        baseURI = uri;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return string(
            abi.encodePacked(baseURI, "?contractAddress=", toString(msg.sender), "&tokenId=", Strings.toString(tokenId))
        );
    }

    function toString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint160(addr), 20);
    }
}
