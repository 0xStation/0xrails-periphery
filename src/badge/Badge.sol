// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./storage/BadgeStorageV0.sol";
import "../lib/token/ERC1155.sol";
import "../lib/renderer/IRenderer.sol";

contract Badge is UUPSUpgradeable, BadgeStorageV0 {
    function _authorizeUpgrade(address newImplementation) internal override {}
}
