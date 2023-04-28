// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../lib/renderer/IRenderer.sol";
import "./storage/MembershipStorageV0.sol";
import "./IMembership.sol";


 contract Membership is IMembership, Initializable, UUPSUpgradeable, ERC721Upgradeable, Ownable, MembershipStorageV0 {
  ///                                                          ///
  ///                         INITIALIZER                      ///
  ///                                                          ///

  /// @dev Initializes the ERC721 Token.
  /// @param owner_ The address to transfer ownership to.
  /// @param renderer_ The address of the renderer.
  /// @param name_ The name of the token.
  /// @param symbol_ The encoded function call
  function initialize(address owner_, address renderer_, string memory name_, string memory symbol_) public initializer {
      _transferOwnership(owner_);
      renderer = renderer_;
      __ERC721_init(name_, symbol_);
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

  function mintTo(address recipient, uint256 tokenId) external onlyOwner {
      _mint(recipient, tokenId);
  }

  function burn(uint256 tokenId, uint256 amount) external onlyOwner {

  }

  function _msgData() internal pure override(ContextUpgradeable, Context) returns (bytes calldata) {
      return msg.data;
  }

  function _msgSender() internal view override(ContextUpgradeable, Context) returns (address) {
      return msg.sender;
  }
}