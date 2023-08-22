// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPayoutAddress {
    // events
    event PayoutAddressUpdated(address oldPayoutAddress, address newPayoutAddress);

    // errors
    error PayoutAddressIsZero();

    // views
    function payoutAddress() external view returns (address);

    // setters
    function setPayoutAddress(address payoutAddress) external;
    function removePayoutAddress() external;
}
