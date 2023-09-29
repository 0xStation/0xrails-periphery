// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "openzeppelin-contracts/token/ERC1155/IERC1155.sol";
import {Ownable} from "0xrails/access/ownable/Ownable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {ISupportsInterface} from "0xrails/lib/ERC165/ISupportsInterface.sol";
import {IERC721Rails} from "0xrails/cores/ERC721/interface/IERC721Rails.sol";
import {IERC20Rails} from "0xrails/cores/ERC20/interface/IERC20Rails.sol";
import {IERC1155Rails} from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
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
        // events are emitted before initialization for indexer convenience
        if (std == TokenStandard.ERC20) { 
            emit PointsCreated(core);
            core = _create(type(IERC20).interfaceId, coreImpl, owner, name, symbol, initData);
       } else if (std == TokenStandard.ERC721) {
            emit MembershipCreated(core);
            core = _create(type(IERC721).interfaceId, coreImpl, owner, name, symbol, initData);
       } else if (std == TokenStandard.ERC1155) {
            emit BadgesCreated(core);
            core = _create(type(IERC1155).interfaceId, coreImpl, owner, name, symbol, initData);
       }
    }

    function _create(
        bytes4 _interfaceId, 
        address _coreImpl, 
        address _owner, 
        string memory _name, 
        string memory _symbol, 
        bytes memory _initData
    ) public returns (address payable _core) {
        if (!ISupportsInterface(_coreImpl).supportsInterface(_interfaceId)) revert InvalidImplementation();
        _core = payable(address(new ERC1967Proxy(_coreImpl, bytes(""))));
        IERC721Rails(_core).initialize(_owner, _name, _symbol, _initData);
    }

    /*===============
        OVERRIDES
    ===============*/

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}