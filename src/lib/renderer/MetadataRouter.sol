// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/utils/Strings.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import "./IMetadataRouter.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {Batch} from "src/lib/Batch.sol";

contract MetadataRouter is Ownable, UUPSUpgradeable, Batch, IMetadataRouter {
    using Strings for uint256;

    string constant _TOKEN = "token";
    string constant _COLLECTION = "collection";
    string constant _MODULE = "module";
    string constant _GUARD = "guard";

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

    function updateDefaultURI(string memory contractType, string memory uri) external onlyOwner {
        _defaultURIs[contractType] = uri;
        emit UpdateDefaultBaseURI(contractType, uri);
    }

    function defaultURI(string memory contractType) public view returns (string memory) {
        return _defaultURIs[contractType];
    }

    function overrideBaseURI(string memory contractType, string memory uri, address contractAddress) external {
        if (
            keccak256(abi.encodePacked(contractType)) != keccak256(abi.encodePacked(_TOKEN))
                || Permissions(contractAddress).hasPermission(msg.sender, Permissions.Operation.RENDER)
        ) {
            revert UnauthorizedOverride(msg.sender, contractType, contractAddress);
        } // TODO: change once enabling module and guard creators to override
        _customURIs[contractType][contractAddress] = uri;
        emit OverrideBaseURI(contractType, uri, contractAddress);
    }

    function baseURI(string memory contractType, address contractAddress) public view returns (string memory uri) {
        uri = _customURIs[contractType][contractAddress];
        if (bytes(uri).length == 0) {
            uri = _defaultURIs[contractType];
        }
    }

    function _getContractURI(string memory contractType, address contractAddress)
        internal
        view
        returns (string memory)
    {
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
        return string(abi.encodePacked(_getContractURI(_TOKEN, collection), "&tokenId=", Strings.toString(tokenId)));
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return tokenURI(msg.sender, tokenId);
    }

    /*================
        COLLECTION
    ================*/

    function collectionURI(address collection) public view returns (string memory) {
        return _getContractURI(_COLLECTION, collection);
    }

    function collectionURI() external view returns (string memory) {
        return collectionURI(msg.sender);
    }

    /*============
        MODULE
    =============*/

    function moduleURI(address module) public view returns (string memory) {
        return _getContractURI(_MODULE, module);
    }

    function moduleURI() external view returns (string memory) {
        return moduleURI(msg.sender);
    }

    /*===========
        GUARD
    ============*/

    function guardURI(address guard) public view returns (string memory) {
        return _getContractURI(_GUARD, guard);
    }

    function guardURI() external view returns (string memory) {
        return guardURI(msg.sender);
    }
}
