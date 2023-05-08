// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDelayedRevealRenderer {
    event UpdatedBaseURI(address token, string uri);
    event Revealed(address token);

    function reveal(address token) external;
    function updateBaseURI(address token, string memory _baseURI) external;
    function tokenURI(address token, uint256 tokenId) external view returns (string memory);
}
