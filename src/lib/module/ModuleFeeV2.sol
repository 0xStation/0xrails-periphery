// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {FeeManager} from "./FeeManager.sol";
import {StablecoinRegistry} from "./storage/StablecoinRegistry.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Station Network Fee Manager Contract
/// @author symmetry (@symmtry69), frog (@0xmcg), 👦🏻👦🏻.eth

/// @dev This contract enables payment by handling funds when charging base and variable fees on each Membership's mints

/// @notice ModuleFeeV2 differs from ModuleFee in that it is intended to be inherited by the PurchaseModule
/// The goal is to abstract all payment logic so this module can handle the GroupOS side of every client's desired Membership implementation

abstract contract ModuleFeeV2 is Ownable {

    /*============
        ERRORS
    ============*/

    error InvalidFee(uint256 expected, uint256 received);
    error FeeCollectFailed();

    /*============
        EVENTS
    ============*/

    event WithdrawFee(address indexed recipient, uint256 amount);

    /*=============
        STORAGE
    =============*/

    /// @dev Address of the deployed FeeManager contract which stores state for all collections' fee information
    /// @dev The FeeManager serves a Singleton role as central fee ledger for modules to read from
    address immutable internal feeManager;

    /// @dev The balance recordkeeping for the specific child contract that inherits from this module
    /// @dev Accounts for the sum of both baseFee and variableFee, which are set in the FeeManager
    uint256 public ethTotalFeeBalance;

    /*=================
        ModuleFeeV2
    =================*/

    /// @param newOwner The initialization of the contract's owner address, managed by Station
    /// @param feeManagerProxy The UUPS proxy that serves as Station's central fee management ledger for all Memberships
    constructor(address newOwner, address feeManagerProxy) {
        _transferOwnership(newOwner);
        feeManager = feeManagerProxy;
    }

    /// @dev Function to withdraw the total balances of accrued base and variable eth fees collected from mints
    /// @dev Sends fees to the module's owner address, which is managed by Station Network
    /// @dev Access control forgone since only the owner will receive the feeBalance
    function withdrawFee() external {
        address recipient = owner();
        uint256 balance = ethTotalFeeBalance;
        ethTotalFeeBalance = 0;

        (bool r,) = payable(recipient).call{ value: balance}('');
        require(r);
        emit WithdrawFee(recipient, balance);
    }

    //todo function to withdraw stablecoin collected fees to owner

    /// @dev Function to update the feeBalance in storage when minting a single item
    /// @param collection The token collection to mint from
    /// @param paymentToken The token address being used for payment
    /// @param recipient The recipient of successfully minted tokens
    function _registerFee(
        address collection, 
        address paymentToken, 
        address recipient,
        uint256 unitPrice
    ) internal returns (uint256 paidFee) {
        return _registerFeeBatch(collection, paymentToken, recipient, 1, unitPrice);
    }

    /// @dev Function to update the feeBalance in storage when fees are paid to this module in ETH
    /// @param n The number of items being minted, used to calculate the total fee payment required
    function _registerFeeBatch(
        address collection, 
        address paymentToken, 
        address recipient, 
        uint256 n,
        uint256 unitPrice
    ) internal returns (uint256 paidFee) {        
        // baseFee and variableFee are handled as ETH or ERC20 stablecoin payment accordingly by FeeManager
        (uint256 baseFee, uint256 variableFee) = FeeManager(feeManager).getFeeTotals(
            collection, 
            paymentToken,
            recipient,
            n, 
            unitPrice
        );
        
        // in free mint context, variableFee will be 0 and baseFee may represent either ETH or ERC20
        paidFee = baseFee + variableFee;
        
        // for ETH context, accept funds only if the msg.value sent matches the FeeManager's calculation
        if (paymentToken == address(0x0)) {
            if (msg.value != paidFee) revert InvalidFee(paidFee, msg.value);
            // update eth fee balances, will revert if interactions fail
            ethTotalFeeBalance += paidFee;
        } 
        // else{} ERC20 approval check with potential custom error to spell out exact error 
    }
}
