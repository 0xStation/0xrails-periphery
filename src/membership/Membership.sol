// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "solmate/src/tokens/ERC721.sol";
import "../lib/renderer/IRenderer.sol";
import "./IMebership.sol";
import "./storage/MembershipStorageV0.sol";

contract Membership is IMembership, Initializable, UUPSUpgradeable, Ownable, ERC721, MembershipStorageV0 {
    function init(address _owner, address _renderer, string memory _name, string memory _symbol) external initializer {
        _transferOwnership(_owner);
        __ERC721_init(_name, _symbol);
        renderer = _renderer;
        emit UpdatedRenderer(_renderer);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        return IRenderer(renderer).tokenURI(id);
    }

    function updateRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
        emit UpdatedRenderer(_renderer);
    }

    function mintTo(address recipient, uint256 tokenId) external onlyOwner {
        _mint(recipient, tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}
