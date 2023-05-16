// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/Pausable.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "./IMembership.sol";
import {Batch} from "src/lib/Batch.sol";

contract MembershipFactory is Ownable, Pausable {
    address public template;

    event MembershipCreated(address indexed membership);

    constructor(address _template, address _owner) Pausable() {
        template = _template;
        _transferOwnership(_owner);
    }

    /// @notice create a new Membership via ERC1967Proxy
    function create(address owner, address renderer, string memory name, string memory symbol)
        public
        whenNotPaused
        returns (address membership)
    {
        bytes memory initData =
            abi.encodeWithSelector(IMembership(template).init.selector, owner, renderer, name, symbol);
        membership = address(new ERC1967Proxy(template, initData));

        emit MembershipCreated(membership);
    }

    /// @notice create a new Membership via ERC1967Proxy and setup other parameters
    function createAndSetup(
        address owner,
        address renderer,
        string memory name,
        string memory symbol,
        bytes[] calldata setupCalls
    ) external whenNotPaused returns (address membership, Batch.Result[] memory setupResults) {
        membership = create(owner, renderer, name, symbol);
        setupResults = Batch(membership).batch(false, setupCalls); // non-atomic batch call
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
