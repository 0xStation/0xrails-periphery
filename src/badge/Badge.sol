// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract Badge is UUPSUpgradeable {
    function _authorizeUpgrade(address newImplementation) internal override {}
}
