// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ERC721Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
// import {ERC721} from "solmate/src/tokens/ERC721.sol";
import "../lib/renderer/IRenderer.sol";
import "../lib/Permissions.sol";
import "./storage/MembershipStorageV0.sol";
import "./IMembership.sol";
import {ITokenGuard} from "src/lib/guard/ITokenGuard.sol";

contract Membership is IMembership, UUPSUpgradeable, Permissions, ERC721Upgradeable, MembershipStorageV0 {
    constructor() {}

    /// @dev Initializes the ERC721 Token.
    /// @param owner_ The address to transfer ownership to.
    /// @param renderer_ The address of the renderer.
    /// @param name_ The name of the token.
    /// @param symbol_ The encoded function call
    function initialize(address owner_, address renderer_, string memory name_, string memory symbol_)
        public
        initializer
        returns (bool success)
    {
        _transferOwnership(owner_);
        _updateRenderer(renderer_);
        __ERC721_init(name_, symbol_);
        return true;
    }

    function _authorizeUpgrade(address newImplementation) internal override permitted(Operation.UPGRADE) {}

    function updateRenderer(address _renderer) external permitted(Operation.RENDER) returns (bool success) {
        _updateRenderer(_renderer);
        return true;
    }

    function _updateRenderer(address _renderer) internal {
        renderer = _renderer;
        emit UpdatedRenderer(_renderer);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return IRenderer(renderer).tokenURI(id);
    }

    function mintTo(address recipient) external permitted(Operation.MINT) returns (uint256 tokenId) {
        tokenId = ++totalSupply;
        _safeMint(recipient, tokenId);
        return tokenId;
    }

    function burnFrom(uint256 tokenId) external permitted(Operation.BURN) returns (bool success) {
        _burn(tokenId);
        return true;
    }

    function burn(uint256 tokenId) external returns (bool success) {
        require(msg.sender == ownerOf(tokenId));
        _burn(tokenId);
        return true;
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256) internal override {
        address guard;
        // MINT
        if (from == address(0)) {
            guard = guards[Operation.MINT];
        }
        // BURN
        else if (to == address(0)) {
            guard = guards[Operation.BURN];
        }
        // TRANSFER
        else {
            guard = guards[Operation.TRANSFER];
        }

        require(
            guard != MAX_ADDRESS && (guard == address(0) || ITokenGuard(guard).isAllowed(msg.sender, from, to, tokenId)),
            "NOT_ALLOWED"
        );
    }
}
