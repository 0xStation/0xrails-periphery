// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./IMembership.sol";

contract MembershipFactory is Ownable, Pausable {
    address public template;

    event MembershipCreated(address indexed membership);

    constructor(address _template, address _owner) Pausable() {
        template = _template;
        _transferOwnership(_owner);
    }

    /// @notice create a new Membership via OZ Clones
    function create(address owner, address renderer, string memory name, string memory symbol)
        external
        whenNotPaused
        returns (address membership)
    {
        membership = Clones.clone(template);
        IMembership(membership).initialize(owner, renderer, name, symbol);

        emit MembershipCreated(membership);
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
