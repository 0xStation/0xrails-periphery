// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Owner} from "mage/access/owner/Owner.sol";

import {IMetadataRouter} from "./IMetadataRouter.sol";

contract MetadataRouter is Owner, UUPSUpgradeable, IMetadataRouter {
    using Strings for uint256;

    string constant _CONTRACT = "contract";
    string constant _MODULE = "module";
    string constant _GUARD = "guard";
    string constant _EXTENSION = "extension";
    string constant _COLLECTION = "collection";
    string constant _TOKEN = "token";

    /*=============
        STORAGE
    ==============*/

    string public baselineURI;
    mapping(string => string) public defaultURI;
    mapping(string => mapping(address => string)) public customURI;

    /*====================
        INITIALIZATION
    ====================*/

    /// @dev todo: change to initializer and use public functions to emit events
    constructor(address _owner, string memory baselineURI_, string[] memory contractTypes, string[] memory uris) {
        uint256 len = contractTypes.length;
        if (len != uris.length) revert();
        for (uint256 i; i < len; i++) {
            defaultURI[contractTypes[i]] = uris[i];
        }
        _transferOwnership(_owner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*===========
        VIEWS
    ===========*/

    // metadata for this MetadataRouter contract
    function contractURI() external view returns (string memory uri) {
        return contractURI(address(this));
    }

    function baseURI(string memory contractType, address contractAddress) public view returns (string memory uri) {
        uri = customURI[contractType][contractAddress];
        if (bytes(uri).length == 0) {
            uri = defaultURI[contractType];
            if (bytes(uri).length == 0) {
                uri = baselineURI;
            }
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

    /*====================
        CORE UTILITIES
    ====================*/

    function updateBaselineURI(string memory uri) external onlyOwner {
        baselineURI = uri;
        emit UpdateBaselineURI(uri);
    }

    function updateDefaultURI(string memory contractType, string memory uri) external onlyOwner {
        defaultURI[contractType] = uri;
        emit UpdateDefaultURI(contractType, uri);
    }

    function updateCustomURI(string memory contractType, string memory uri, address contractAddress)
        external
        onlyOwner
    {
        customURI[contractType][contractAddress] = uri;
        emit UpdateCustomURI(contractType, uri, contractAddress);
    }

    /*============
        ROUTES
    ============*/

    function contractURI(address contract_) public view returns (string memory) {
        return _getContractURI(_CONTRACT, contract_);
    }

    function moduleURI(address module) public view returns (string memory) {
        return _getContractURI(_MODULE, module);
    }

    function guardURI(address guard) public view returns (string memory) {
        return _getContractURI(_GUARD, guard);
    }

    function extensionURI(address extension) public view returns (string memory) {
        return _getContractURI(_EXTENSION, extension);
    }

    function collectionURI(address collection) public view returns (string memory) {
        return _getContractURI(_COLLECTION, collection);
    }

    function tokenURI(address collection, uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(_getContractURI(_TOKEN, collection), "&tokenId=", Strings.toString(tokenId)));
    }
}
