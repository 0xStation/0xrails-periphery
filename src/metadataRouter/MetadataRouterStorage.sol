// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library MetadataRouterStorage {
    bytes32 internal constant SLOT = bytes32(uint256(keccak256("groupos.MetadataRouter")) - 1);

    struct Layout {
        string defaultURI;
        mapping(string => string) routeURI;
        mapping(string => mapping(address => string)) contractRouteURI;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
