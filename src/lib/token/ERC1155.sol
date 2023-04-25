// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155 as SolmateERC1155} from "solmate/src/tokens/ERC1155.sol";
import {IRenderer} from "../renderer/IRenderer.sol";

contract ERC1155 is SolmateERC1155 {
    string public name;
    string public symbol;
    address public renderer;

    constructor(string memory _name, string memory _symbol, address _renderer) {
        _init(_name, _symbol, _renderer);
    }

    function _init(string memory _name, string memory _symbol, address _renderer) internal {
        name = _name;
        symbol = _symbol;
        renderer = _renderer;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return IRenderer(renderer).tokenURI(id);
    }
}
