// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "solmate/src/tokens/ERC721.sol";
import "../lib/renderer/IRenderer.sol";
import "../lib/Permissions.sol";
import "./storage/MembershipStorageV0.sol";
import "./IMembership.sol";

contract Membership is IMembership, Initializable, UUPSUpgradeable, Permissions, ERC721, MembershipStorageV0 {
    constructor() ERC721("", "") {}

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    /// @dev Initializes the ERC721 Token.
    /// @param owner_ The address to transfer ownership to.
    /// @param renderer_ The address of the renderer.
    /// @param name_ The name of the token.
    /// @param symbol_ The encoded function call
    function initialize(address owner_, address renderer_, string memory name_, string memory symbol_)
        public
        initializer
    {
        _transferOwnership(owner_);
        renderer = renderer_;
        name = name_;
        symbol = symbol_;
        emit UpdatedRenderer(renderer_);
    }

    ///                                                          ///
    ///                        METHODS                           ///
    ///                                                          ///

    function updateRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
        emit UpdatedRenderer(_renderer);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return IRenderer(renderer).tokenURI(id);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function mintTo(address recipient) external permitted(Operation.MINT) {
        _mint(recipient, totalSupply++);
    }

    function burnFrom(uint256 tokenId) external permitted(Operation.BURN) {
        _burn(tokenId);
    }
}
