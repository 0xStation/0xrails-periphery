// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IBadgesFactory {
    event BadgesUpdated(address indexed badgesImpl);
    event BadgesCreated(address indexed badges);

    error InvalidImplementation();

    function badgesImpl() external view returns (address);

    function initialize(address badgesImpl_, address owner_) external;

    function create(address owner, string memory name, string memory symbol, bytes calldata initData)
        external
        returns (address badges);
}
