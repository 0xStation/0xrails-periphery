// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {FeeManager} from "src/lib/module/FeeManager.sol";

/// @dev Script to deploy *all* GroupOS contracts other than the Safe and AdminGuard
/// Usage:
///   forge script script/SetDefaultFee.s.sol:SetDefaultFeeScript \
///     --keystore $KS --password $PW --sender $sender \
///     --fork-url $RPC_URL --broadcast -vvvv \
contract SetDefaultFeeScript is ScriptUtils {

    /*=================
        ENVIRONMENT 
    =================*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    DeploysJson $deploys = setDeploysJsonStruct();

    Call3[] calls;

    /*============
        CONFIG
    ============*/

    FeeManager feeManager = FeeManager($deploys.FeeManager);
    address owner = $deploys.StationFounderSafe;

    /// @notice Configure the following values before running!
    uint256 newDefaultBaseFee = 0;
    uint256 newDefaultVariableFee = 0;

    function run() public {

        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        // format calls to be routed through the owner
        bytes memory setNewDefaultFees = abi.encodeWithSelector(
            FeeManager.setDefaultFees.selector, newDefaultBaseFee, newDefaultVariableFee
        );
        Call3 memory setNewDefaultFeesCall = Call3({
            target: address(feeManager), allowFailure: false, callData: setNewDefaultFees
        });
        calls.push(setNewDefaultFeesCall);

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        
        (bool r,) = owner.call(safeCall);
        require(r);

        // assert FeeManager's default fees have been updated
        assert(feeManager.getDefaultFees().exist);
        assert(feeManager.getDefaultFees().baseFee == newDefaultBaseFee);
        assert(feeManager.getDefaultFees().variableFee == newDefaultVariableFee);

        vm.stopBroadcast();
    }
}
