// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "0xrails/access/ownable/Ownable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import {IBadgesFactory} from "./IBadgesFactory.sol";
import {BadgesFactoryStorage} from "./BadgesFactoryStorage.sol";

/// @title GroupOS ERC1155 Badges Factory
/// @author symmetry (@symmtry69)
/// @dev Contract to create ERC1155 Badges as proxies that delegate to a singleton implementation contract
contract BadgesFactory is Initializable, Ownable, UUPSUpgradeable, IBadgesFactory {
    /*============
        SET UP
    ============*/

    constructor() Initializable() {}

    /// @inheritdoc IBadgesFactory
    function initialize(address badgesImpl_, address owner_) external initializer {
        _updateBadgesImpl(badgesImpl_);
        _transferOwnership(owner_);
    }

    /// @inheritdoc IBadgesFactory
    function badgesImpl() public view returns (address) {
        return BadgesFactoryStorage.layout().badgesImpl;
    }

    /// @inheritdoc IBadgesFactory
    function setBadgesImpl(address newImpl) external onlyOwner {
        _updateBadgesImpl(newImpl);
    }

    function _updateBadgesImpl(address newImpl) internal {
        if (newImpl == address(0)) revert InvalidImplementation();
        BadgesFactoryStorage.Layout storage layout = BadgesFactoryStorage.layout();
        layout.badgesImpl = newImpl;
        emit BadgesUpdated(newImpl);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*============
        CREATE
    ============*/

    /// @inheritdoc IBadgesFactory
    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address badges)
    {
        badges = address(new ERC1967Proxy(badgesImpl(), bytes("")));
        emit BadgesCreated(badges); // put BadgesCreated before initialization events for indexer convenience
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC721Rails(badges).initialize(owner, name, symbol, initData);
    }
}
