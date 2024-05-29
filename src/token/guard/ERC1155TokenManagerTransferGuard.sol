// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IGuard} from "0xrails/guard/interface/IGuard.sol";
import {SetupModule} from "src/lib/module/SetupModule.sol";

/// @title ERC1155TokenManagerTransferGuard Contract
/// @author Conner (@ilikesymmetry)
contract ERC1155TokenManagerTransferGuard is IGuard, SetupModule {
    error NotTokenManager(uint256 tokenId, address operator, address from, address to);

    event TokenManagerUpdated(address indexed collection, uint256 indexed tokenId, address indexed manager);

    // collection => tokenId => token manager
    mapping(address => mapping(uint256 => address)) internal _tokenManagers;

    /*=============
        SETTERS
    =============*/

    function setUp(address collection, uint256[] calldata tokenIds, address[] calldata tokenManagers)
        public
        canSetUp(collection)
    {
        uint256 len = tokenIds.length;
        require(len == tokenManagers.length, "lengths differ");
        for (uint256 i; i < len; i++) {
            _tokenManagers[collection][tokenIds[i]] = tokenManagers[i];
            emit TokenManagerUpdated(collection, tokenIds[i], tokenManagers[i]);
        }
    }

    /// @dev convenience function for setting up using multicall from collection
    function setUp(uint256[] calldata tokenIds, address[] calldata tokenManagers) external {
        setUp(msg.sender, tokenIds, tokenManagers);
    }

    /*===========
        VIEWS
    ===========*/

    /// @notice Get the token manager for a specific tokenId on an ERC1155 collection
    /// @param collection address of ERC1155 token contract
    /// @param tokenId id of specific token in ERC1155 collection
    function getTokenManager(address collection, uint256 tokenId) external view returns (address) {
        return _tokenManagers[collection][tokenId];
    }

    /// @dev Hook to perform pre-call checks and return guard information.
    /// @param data The data associated with the action, including relevant parameters.
    /// @return checkBeforeData Additional data to be passed to the `checkAfter` function.
    function checkBefore(address, bytes calldata data) external view returns (bytes memory checkBeforeData) {
        // (address operator, address from, address to, uint256[] ids, uint256[] values)
        (address operator, address from, address to, uint256[] memory ids,) =
            abi.decode(data, (address, address, address, uint256[], uint256[]));

        uint256 len = ids.length;
        for (uint256 i; i < len; i++) {
            address manager = _tokenManagers[msg.sender][ids[i]];
            // deny token transfer requests that are not set to the operator, from, or to
            // operator, from, and to will never be address(0) if used as a Transfer guard,
            // so default manager value address(0) provides non-transferable default
            if (!(manager == operator || manager == from || manager == to)) {
                revert NotTokenManager(ids[i], operator, from, to);
            }
        }
    }

    /// @dev Hook to perform post-call checks.
    /// @param checkBeforeData Data passed from the `checkBefore` function.
    function checkAfter(bytes calldata checkBeforeData, bytes calldata) external view {}
}
