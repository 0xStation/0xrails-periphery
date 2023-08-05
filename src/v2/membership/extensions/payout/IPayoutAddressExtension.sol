// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPayoutAddressExtensionInternal {
    // events
    event PayoutAddressUpdated(address oldPayoutAddress, address newPayoutAddress);

    // errors
    error PayoutAddressIsZero();

    // views
    function payoutAddress() external view returns (address);
}

interface IPayoutAddressExtensionExternal {
    // setters
    function updatePayoutAddress(address payoutAddress) external;
}

interface IPayoutAddressExtension is IPayoutAddressExtensionInternal, IPayoutAddressExtensionExternal {}
