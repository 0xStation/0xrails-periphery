// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMembership} from "src/membership/IMembership.sol";
import {Membership} from "src/membership/Membership.sol";
import {Permissions} from "src/lib/Permissions.sol";
// module utils
import {ModuleSetup} from "src/lib/module/ModuleSetup.sol";
import {ModuleGrant} from "src/lib/module/ModuleGrant.sol";
import {ModuleFee} from "src/lib/module/ModuleFee.sol";
// use SafeERC20: https://soliditydeveloper.com/safe-erc20
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Station Network PurchaseModule Contract
/// @author 👦🏻👦🏻.eth

/// @dev This contract handles payment configurations for all Membership collections in both ETH and Stablecoins, including free mints
/// The goal is to abstract all client-facing payment logic so this module can be used as a strikingly simple plugin for clients and developers to customize

/// TODO Should be converted to a UUPS proxy for upgradeability once approved for production

contract PurchaseModule is ModuleGrant, ModuleFeeV2, ModuleSetup, StablecoinRegistry {
    using SafeERC20 for IERC20Metadata;

    /// @dev Struct of collection price data, including options for both ETH and stablecoins
    /// @param ethPrice The price in ETH set for a collection's mint
    /// @param stablecoinPrice The price in stablecoins set for a collection's mint
    /// @param enabledCoins A bitmap of single byte keys that correspond to supported stablecoins, managed by the StablecoinRegistry contract
    struct PurchaseConfig {
        uint256 ethPrice;
        uint128 stablecoinPrice;
        bytes16 enabledCoins;
    }

    /*============
        EVENTS
    ============*/
    //todo will use preexisting events from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility

    /*=============
        STORAGE
    =============*/

    // decimals of precision for most common stablecoins (USDC + USDT), stored in runtime bytecode to save gas
    uint8 public constant decimals = 6;
    // how many keys currently exist in map
    uint8 public keyCounter;

    /// @dev Mapping of stablecoin address => associated key in bitmap
    mapping(address => uint8) internal _keyOf;

    /// @dev Mapping of bitmap key => stablecoin address
    mapping(uint8 => address) internal _stablecoinOf;

    /// @dev Mapping of each collection => mint purchase configuration
    mapping(address => PurchaseConfig) internal _collectionConfig;

    /// @dev Mapping to show if a collection prevents or allows minting via signature grants, ie collection address => repealGrants
    /// @notice todo Can significantly improve gas efficiency here by using `uint 1 || 2` as opposed to `bool 0 || 1` due to repeated cold slot (ie 0) initialization costs
    mapping(address => bool) internal _repealGrants;

    /*============
        CONFIG
    ============*/
    //todo will use preexisting config and setup logic from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility

    /*==========
        MINT
    ==========*/
    //todo will use preexisting mint logic from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility

    // add checks and post-effect asserts to the preexisting mint logics to ensure that the parent ModuleFeeV2 contract's recordkeeping (of address(this).balance) is unexploitable

    /*==========
        VIEWS
    ==========*/
    //todo will use preexisting view functions from StablecoinPurchaseModuleV2 and EthPurchaseModuleV2 to ensure backwards compatibility
    
    // function priceOf(address collection) external view returns (PurchaseConfig prices) {
        // should check if eth price set
        // should check if stablecoin price is set
        // should check which stablecoins are enabled
        // require(ethPrice > 0 || stablecoinPrice > 0, "NO_PRICE");
    // }

    // function mintPriceToStablecoinAmount(uint256 price, address stablecoin) public view returns (uint256) {}

    // function enabledCoinsOf(address collection) external view returns (address[] memory stablecoins) {
    //     for loop of keys  { while key < 4 { _getAddress(key);}
    // }

    // function stablecoinEnabled(address colection, address stablecoin) external view returns (bool) {}

    /*==============
        INTERNALS
    ==============*/

    /// @dev Function to check if a stablecoinAddress is already registered and possesses a bitmap key in storage state
    // function _isRegistered(address stablecoinAddress) internal returns (bool) {}

    /// @dev Function to register a new stablecoinAddress (other than the common defaults in StablecoinRegistry) that collection would like to support
    // function _registerStablecoin(address newStablecoin) internal returns (uint8 newKey) {}

    /*============
        GRANTS
    ============*/
    
    /// @notice Grant logic from both StablecoinPurchaseModuleV2 and EthPurchaseModuleV2, consolidated into this single contract to reduce redundance
    function validateGrantSigner(bool grantInProgress, address signer, bytes memory callContext)
        public
        view
        override
        returns (bool)
    {
        address collection = abi.decode(callContext, (address));
        return (grantInProgress && Permissions(collection).hasPermission(signer, Permissions.Operation.GRANT))
            || (!grantsEnforced(collection));
    }

    function grantsEnforced(address collection) public view returns (bool) {
        return !_repealGrants[collection];
    }
}