// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract Renderer is UUPSUpgradeable {
    string baseURI;

    constructor() {
        baseURI = "token.station.express/api/v1/metadata/";
    }

    function _authorizeUpgrade(address newImplementation) internal override {}
}
