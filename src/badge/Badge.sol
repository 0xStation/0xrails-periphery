// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "solmate/src/tokens/ERC1155.sol";
import "./storage/BadgeStorageV0.sol";
import "../lib/renderer/IRenderer.sol";
import "../lib/Permissions.sol";
import "./IBadge.sol";

contract Badge is IBadge, Initializable, UUPSUpgradeable, Permissions, ERC1155, BadgeStorageV0 {
    function init(address _owner, address _renderer, string memory _name, string memory _symbol) external initializer {
        _transferOwnership(_owner);
        renderer = _renderer;
        name = _name;
        symbol = _symbol;
        emit UpdatedRenderer(_renderer);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function uri(uint256 id) public view override returns (string memory) {
        return IRenderer(renderer).tokenURI(id);
    }

    function updateRenderer(address _renderer) external onlyOwner returns (bool) {
        renderer = _renderer;
        emit UpdatedRenderer(_renderer);
        return true;
    }

    function mintTo(address recipient, uint256 tokenId) external permitted(Operation.MINT) returns (bool) {
        _mint(recipient, tokenId, 1, "");
        return true;
    }

    function burnFrom(address account, uint256 tokenId, uint256 amount)
        external
        permitted(Operation.BURN)
        returns (bool)
    {
        _burn(account, tokenId, amount);
        return true;
    }

    function burn(uint256 tokenId, uint256 amount) external returns (bool) {
        _burn(msg.sender, tokenId, amount);
        return true;
    }
}
