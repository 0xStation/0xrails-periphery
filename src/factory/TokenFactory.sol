// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "openzeppelin-contracts/token/ERC1155/IERC1155.sol";
import {Ownable} from "0xrails/access/ownable/Ownable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {ERC20Rails} from "0xrails/cores/ERC20/ERC20Rails.sol";
import {ERC1155Rails} from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";

contract TokenFactory is Initializable, Ownable, UUPSUpgradeable, ITokenFactory {

    /*============
        SET UP
    ============*/

    constructor() Initializable() {}

    /// @inheritdoc ITokenFactory
    function initialize(address owner_) external initializer {
        _transferOwnership(owner_);
    }

    /*============
        CREATE
    ============*/

    /// @inheritdoc ITokenFactory
    function create(TokenStandard std, address payable coreImpl, address owner, string memory name, string memory symbol, bytes calldata initData) 
        public 
        returns (address payable core)
    {
        if (std == TokenStandard.ERC20) { 
            if (!ERC20Rails(coreImpl).supportsInterface(type(IERC20).interfaceId)) revert InvalidImplementation();
            core = _create(coreImpl);

            // emit event before initialization for indexer convenience
            emit PointsCreated(core);

            // initializer relies on self-delegatecall so make a separate call to initialize after deploying new proxy
            ERC20Rails(core).initialize(owner, name, symbol, initData);
       } else if (std == TokenStandard.ERC721) {
            if (!ERC721Rails(coreImpl).supportsInterface(type(IERC721).interfaceId)) revert InvalidImplementation();
            core = _create(coreImpl);

            // emit event before initialization for indexer convenience
            emit MembershipCreated(core);

            // initializer relies on self-delegatecall so make a separate call to initialize after deploying new proxy
            ERC721Rails(core).initialize(owner, name, symbol, initData);
       } else if (std == TokenStandard.ERC1155) {
            if (!ERC1155Rails(coreImpl).supportsInterface(type(IERC1155).interfaceId)) revert InvalidImplementation();
            core = _create(coreImpl);

            // emit event before initialization for indexer convenience
            emit BadgesCreated(core);

            // initializer relies on self-delegatecall so make a separate call to initialize after deploying new proxy
            ERC1155Rails(core).initialize(owner, name, symbol, initData);
       }
    }

    function _create(address _coreImpl) public returns (address payable _core) {
        _core = payable(address(new ERC1967Proxy(_coreImpl, bytes(""))));
    }

    /*===============
        OVERRIDES
    ===============*/

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}