// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "mage/access/ownable/Ownable.sol";
import {Initializable} from "mage/lib/initializable/Initializable.sol";
import {IERC721Mage} from "mage/cores/ERC721/interface/IERC721Mage.sol";

import {IPointsFactory} from "./IPointsFactory.sol";
import {PointsFactoryStorage} from "./PointsFactoryStorage.sol";

contract PointsFactory is Initializable, Ownable, UUPSUpgradeable, IPointsFactory {
    /*============
        SET UP
    ============*/

    constructor() Initializable() {}

    function initialize(address pointsImpl_, address owner_) external initializer {
        _updatePointsImpl(pointsImpl_);
        _transferOwnership(owner_);
    }

    function pointsImpl() public view returns (address) {
        return PointsFactoryStorage.layout().pointsImpl;
    }

    function setPointsImpl(address newImpl) external onlyOwner {
        _updatePointsImpl(newImpl);
    }

    function _updatePointsImpl(address newImpl) internal {
        if (newImpl == address(0)) revert InvalidImplementation();
        PointsFactoryStorage.Layout storage layout = PointsFactoryStorage.layout();
        layout.pointsImpl = newImpl;
        emit PointsUpdated(newImpl);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*============
        CREATE
    ============*/

    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        public
        returns (address points)
    {
        points = address(new ERC1967Proxy(pointsImpl(), bytes("")));
        emit PointsCreated(points); // put PointsCreated before initialization events for indexer convenience
        // initializer relies on self-delegatecall which does not work when passed through a proxy's constructor
        // make a separate call to initialize after deploying new proxy
        IERC721Mage(points).initialize(owner, name, symbol, initData);
    }

    // non-payable fallback to reject accidental inbound ETH transfer
    fallback() external {}
}
