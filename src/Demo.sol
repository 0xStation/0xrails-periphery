// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "solmate/src/tokens/ERC1155.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Owned} from "solmate/src/auth/Owned.sol";

contract Demo is ERC1155, Owned {
    using Strings for uint256;

    string public name;
    string public symbol;
    string internal baseURI;

    constructor(address _owner, string memory _name, string memory _symbol, string memory _baseURI) Owned(_owner) {
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(
            abi.encodePacked(
                baseURI,
                "?contractAddress=",
                Strings.toHexString(uint160(address(this)), 20),
                "&tokenId=",
                Strings.toString(id)
            )
        );
    }

    function updateBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function mint(address recipient, uint256 tokenId) external onlyOwner {
        _mint(recipient, tokenId, 1, "");
    }
}
