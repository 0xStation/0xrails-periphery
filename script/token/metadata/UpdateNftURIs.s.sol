// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "lib/protocol-ops/script/ScriptUtils.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {MetadataRouter} from "src/metadataRouter/MetadataRouter.sol";

/// @dev Script to update a uri for a given collection and route.
/// Usage:
//   forge script script/token/metadata/UpdateNftURIs.s.sol:UpdateNftURIs \
//     --keystore $KS --password $PW --sender $SENDER \
//     --fork-url $RPC_URL --broadcast -vvvv \
contract UpdateNftURIs is ScriptUtils {
    /*=================
        ENVIRONMENT 
    =================*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    DeploysJson $deploys = setDeploysJsonStruct();

    Call3[] calls;

    /*============
        CONFIG
    ============*/

    MetadataRouter metadataRouter = MetadataRouter($deploys.MetadataRouterProxy);
    address owner = $deploys.StationFounderSafe;

    function run() public {
        /*===============
            BROADCAST 
        ===============*/

        vm.startBroadcast();

        /// @notice Configure the following values before running!
        string memory tokenUri = "https://www.cryptodatabytes.com/api/nft/metadata";
        string memory contractUri = "https://www.cryptodatabytes.com/api/contract";

        address[] memory contracts = new address[](1);
        contracts[0] = 0x4Fc7be21c4437f6D56DF01B1BA38f8B361AeE9e4; // byte light
        // contracts[0] = 0x9C46FE757ea200dFba1A77d1300F77289D8314Cd; // bytexplorer passport
        // contracts[1] = 0xCbD623F16e92023660549B130529B3876F6893b9; // bytexplorer tiers
        // contracts[2] = 0xA014F6649667c73B108F611413916324e9276Eab; // guild tokens
        // contracts[3] = 0x022C7A578dc7C9731D5264661f8486E807dC2A6B; // byte insight

        for (uint256 i; i < contracts.length; i++) {
            address collection = contracts[i];

            // format calls to be routed through the owner
            bytes memory setTokenRoute =
                abi.encodeWithSelector(MetadataRouter.setContractRouteURI.selector, "token", tokenUri, collection);
            Call3 memory setTokenRouteCall =
                Call3({target: address(metadataRouter), allowFailure: false, callData: setTokenRoute});
            calls.push(setTokenRouteCall);

            bytes memory setContractRoute =
                abi.encodeWithSelector(MetadataRouter.setContractRouteURI.selector, "contract", contractUri, collection);
            Call3 memory setContractRouteCall =
                Call3({target: address(metadataRouter), allowFailure: false, callData: setContractRoute});
            calls.push(setContractRouteCall);
        }

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );

        (bool r,) = owner.call(safeCall);
        require(r);

        for (uint256 i; i < contracts.length; i++) {
            address collection = contracts[i];

            // assert metadataRouter's routes have been updated
            assert(
                keccak256(abi.encodePacked(metadataRouter.contractRouteURI("token", collection)))
                    == keccak256(abi.encodePacked(tokenUri))
            );
            assert(
                keccak256(abi.encodePacked(metadataRouter.contractRouteURI("contract", collection)))
                    == keccak256(abi.encodePacked(contractUri))
            );
        }

        vm.stopBroadcast();
    }
}
