// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import {IBeacon} from "openzeppelin-contracts/proxy/beacon/IBeacon.sol";
import {ERC1967Upgrade} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {StorageSlot} from "openzeppelin-contracts/utils/StorageSlot.sol";
import {Permissions} from "src/lib/Permissions.sol";
import {AbstractProxy} from "src/lib/beacon/AbstractProxy.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from an {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract MembershipBeaconProxy is AbstractProxy, ERC1967Upgrade {

    bytes32 private constant _CUSTOM_IMPL_SLOT = bytes32(uint256(keccak256("station.express.beacon.override.customImpl")) - 1);


    /**
     * @dev wrapper around the `permitted` modifier in the Permissions contract 
     * Need a custom modifier because Permissions is inherited at the implementation level (Membership contract), not at the proxy level
     * Inheriting Permissions at the proxy level and at the implementation level leads to variable overrides because of memory address collision
     */
    modifier proxyCheckPermission(Permissions.Operation operation) {
        require(Permissions(address(this)).hasPermission(msg.sender, operation), "NOT_PERMITTED");
        _;
    }

    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializing the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        _upgradeBeaconToAndCall(beacon, data, false);
        _setCustomImpl(address(0));
    }

    function addCustomImplementation(address customImpl) public proxyCheckPermission(Permissions.Operation.UPGRADE) {
        require(Address.isContract(customImpl), "MembershipBeacon: custom implementation is not a contract");
        _setCustomImpl(customImpl);

    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    function implementation() external view returns (address) {
        return _implementation();
    }

    function _getCustomImpl() internal view returns (address) {
        return StorageSlot.getAddressSlot(_CUSTOM_IMPL_SLOT).value;
    }

    function _setCustomImpl(address customImpl) private {
        StorageSlot.getAddressSlot(_CUSTOM_IMPL_SLOT).value = customImpl;
    }

    function switchFromCustomToBeacon() public proxyCheckPermission(Permissions.Operation.UPGRADE) {
        _setCustomImpl(address(0));
    } 

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        if (_getCustomImpl() == address(0)) {
            return IBeacon(_getBeacon()).implementation();
        } else {
            return _getCustomImpl();
        }
    }
}
