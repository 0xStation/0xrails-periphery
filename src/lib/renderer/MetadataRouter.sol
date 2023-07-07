// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/utils/Strings.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import "./IMetadataRouter.sol";
import {Permissions} from "src/lib/Permissions.sol";

contract MetadataRouter is Ownable, UUPSUpgradeable, IMetadataRouter {
    using Strings for uint256;

    /*=============
        STORAGE
    ==============*/

    mapping(string => string) internal _defaultURIs;
    mapping(string => mapping(address => string)) internal _customURIs;

    /*====================
        INITIALIZATION
    ====================*/

    constructor(address _owner, string[] memory contractTypes, string[] memory uris) {
        uint256 len = contractTypes.length;
        if (len != uris.length) revert();
        for (uint256 i; i < len; i++) {
            _defaultURIs[contractTypes[i]] = uris[i];
        }
        _transferOwnership(_owner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*====================
        CORE UTILITIES
    ====================*/

    function updateDefaultURI(string contractType, string memory uri) external onlyOwner {
        _defaultURIs[contractType] = uri;
        emit UpdateDefaultBaseURI(contractType, uri);
    }

    function defaultURI(string contractType) public view returns (string memory) {
        return _defaultURIs[contractType];
    }

    function overrideBaseURI(string contractType, string memory uri, address contractAddress) external {
        if (
            contractType != string.TOKEN
                || Permissions(contractAddress).hasPermission(msg.sender, Permissions.Operation.RENDER)
        ) {
            revert UnauthorizedOverride(msg.sender, contractType, contractAddress);
        } // TODO: change once enabling module and guard creators to override
        _customURIs[contractType][contractAddress] = uri;
        emit OverrideBaseURI(contractType, uri, contractAddress);
    }

    function baseURI(string contractType, address contractAddress) public view returns (string memory uri) {
        uri = _customURIs[contractType][contractAddress];
        if (bytes(uri).length == 0) {
            uri = _defaultURIs[contractType];
        }
    }

    function _getContractURI(string contractType, address contractAddress) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                baseURI(contractType, contractAddress),
                "?chainId=",
                Strings.toString(block.chainid),
                "&contractAddress=",
                Strings.toHexString(uint160(contractAddress), 20)
            )
        );
    }

    /*===========
        TOKEN
    ============*/

    function tokenURI(address collection, uint256 tokenId) public view returns (string memory) {
        return
            string(abi.encodePacked(_getContractURI(string.TOKEN, collection), "&tokenId=", Strings.toString(tokenId)));
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return tokenURI(msg.sender, tokenId);
    }

    /*================
        COLLECTION
    ================*/

    function collectionURI(address collection) public view returns (string memory) {
        return _getContractURI(string.COLLECTION, collection);
    }

    function collectionURI() external view returns (string memory) {
        return collectionURI(msg.sender);
    }

    /*============
        MODULE
    =============*/

    function moduleURI(address module) public view returns (string memory) {
        return _getContractURI(string.MODULE, module);
    }

    function moduleURI() external view returns (string memory) {
        return moduleURI(msg.sender);
    }

    /*===========
        GUARD
    ============*/

    function guardURI(address guard) public view returns (string memory) {
        return _getContractURI(string.GUARD, guard);
    }

    function guardURI() external view returns (string memory) {
        return guardURI(msg.sender);
    }
}
