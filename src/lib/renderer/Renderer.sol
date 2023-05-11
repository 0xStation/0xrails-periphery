// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./IRenderer.sol";
import {Permissions} from "src/lib/Permissions.sol";

contract Renderer is IRenderer, Ownable {
    using Strings for uint256;

    string public baseURI;
    mapping(address => string) public customURI;

    constructor(address _owner, string memory _baseURI) {
        _transferOwnership(_owner);
        baseURI = _baseURI;
    }

    function updateBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit UpdatedBaseURI(_baseURI);
    }

    function updateCustomURI(address collection, string memory uri) external {
        require(Permissions(collection).hasPermission(msg.sender, Permissions.Operation.RENDER), "NOT_ALLOWED");
        customURI[collection] = uri;
        emit UpdatedCustomURI(collection, uri);
    }

    function resolveBaseURI(address collection) public view returns (string memory uri) {
        uri = customURI[collection];
        if (bytes(uri).length == 0) {
            uri = baseURI;
        }
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        uint256 chainId = block.chainid;
        address collection = msg.sender;

        return string(
            abi.encodePacked(
                resolveBaseURI(collection),
                "?chainId=",
                Strings.toString(chainId),
                "&contractAddress=",
                Strings.toHexString(uint160(collection), 20),
                "&tokenId=",
                Strings.toString(tokenId)
            )
        );
    }
}
