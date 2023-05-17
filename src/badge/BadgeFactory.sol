// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/Pausable.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./IBadge.sol";
import {Batch} from "src/lib/Batch.sol";
import {Permissions} from "src/lib/Permissions.sol";

contract BadgeFactory is Ownable, Pausable {
    address public template;

    event BadgeCreated(address indexed badge);

    constructor(address _template, address _owner) Pausable() {
        template = _template;
        _transferOwnership(_owner);
    }

    /// @notice create a new Badge via via ERC1967Proxy
    function create(address owner, address renderer, string memory name, string memory symbol)
        public
        whenNotPaused
        returns (address badge)
    {
        bytes memory initData = abi.encodeWithSelector(IBadge(template).init.selector, owner, renderer, name, symbol);
        badge = address(new ERC1967Proxy(template, initData));

        emit BadgeCreated(badge);
    }

    /// @notice create a new Badge via ERC1967Proxy and setup other parameters
    function createAndSetup(
        address owner,
        address renderer,
        string memory name,
        string memory symbol,
        bytes[] calldata setupCalls
    ) external whenNotPaused returns (address badge, Batch.Result[] memory setupResults) {
        // set factory as owner so it can make calls to protected functions for setup
        badge = create(address(this), renderer, name, symbol);
        // make non-atomic batch call, using permission as owner to do anything
        setupResults = Batch(badge).batch(false, setupCalls);
        // transfer ownership to provided argument
        Permissions(badge).transferOwnership(owner);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // protect against accidental renouncing
    function renounceOwnership() public view override onlyOwner {
        revert("cannot renounce");
    }

    fallback() external {}
}
