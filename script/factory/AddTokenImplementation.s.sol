// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ScriptUtils} from "protocol-ops/script/ScriptUtils.sol";
import {JsonManager} from "protocol-ops/script/lib/JsonManager.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "0xrails/lib/initializable/Initializable.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {TokenFactoryStorage} from "src/factory/TokenFactoryStorage.sol";
import {ERC2771ContextInitializable} from "0xrails/lib/ERC2771/ERC2771ContextInitializable.sol";

/// @dev Script to deploy entire AccountGroup infra to new chains
contract ImplementationTokenFactoryScript is ScriptUtils {
    /*=================
        ENVIRONMENT
    =================*/

    /// @notice Checkout lib/protocol-ops vX.Y.Z to automatically get addresses
    JsonManager.DeploysJson $deploys = setDeploysJsonStruct();
    address owner = $deploys.StationFounderSafe;

    // The following contracts will be targeted:
    address tokenFactory = $deploys.TokenFactoryProxy; // production proxy

    // The following implementations will be added to the target:
    address erc20Impl = 0xD1B501C37671D990711918656eddD8f0bf7B0357;
    address erc721Impl = 0xf4A5268B311b0d30C5eed9A678B1b7c2C1Aa238F;
    address erc1155Impl = 0x741A5a548e11f5EE460D2871526eeEe19584A890;

    function run() public {
        /*===============
            BROADCAST
        ===============*/

        vm.startBroadcast();

        // configure addImplementation function calls
        TokenFactoryStorage.TokenImpl memory newERC20Impl = TokenFactoryStorage.TokenImpl({
            implementation: erc20Impl,
            tokenStandard: TokenFactoryStorage.TokenStandard.ERC20
        });
        bytes memory addImplementationERC20 = abi.encodeWithSelector(TokenFactory.addImplementation.selector, newERC20Impl);
        Call3 memory addImplementationCallERC20 =
            Call3({target: tokenFactory, allowFailure: false, callData: addImplementationERC20});

        TokenFactoryStorage.TokenImpl memory newERC721Impl = TokenFactoryStorage.TokenImpl({
            implementation: erc721Impl,
            tokenStandard: TokenFactoryStorage.TokenStandard.ERC721
        });
        bytes memory addImplementationERC721 = abi.encodeWithSelector(TokenFactory.addImplementation.selector, newERC721Impl);
        Call3 memory addImplementationCallERC721 =
            Call3({target: tokenFactory, allowFailure: false, callData: addImplementationERC721});
    
        TokenFactoryStorage.TokenImpl memory newERC1155Impl = TokenFactoryStorage.TokenImpl({
            implementation: erc1155Impl,
            tokenStandard: TokenFactoryStorage.TokenStandard.ERC1155
        });
        bytes memory addImplementationERC1155 = abi.encodeWithSelector(TokenFactory.addImplementation.selector, newERC1155Impl);
        Call3 memory addImplementationCallERC1155 =
            Call3({target: tokenFactory, allowFailure: false, callData: addImplementationERC1155});

        Call3[] memory calls = new Call3[](3);
        calls[0] = addImplementationCallERC20;
        calls[1] = addImplementationCallERC721;
        calls[2] = addImplementationCallERC1155;

        bytes memory multicallData = abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls);
        // `Safe(owner).execTransactionFromModule(multicall3, 0, multicallData, uint8(1));` using 0 ETH value & Operation == DELEGATECALL
        bytes memory safeCall = abi.encodeWithSignature(
            "execTransactionFromModule(address,uint256,bytes,uint8)", multicall3, 0, multicallData, uint8(1)
        );
        (bool r,) = owner.call(safeCall);
        require(r);

        assert(TokenFactory(tokenFactory).getApprovedImplementations(TokenFactoryStorage.TokenStandard.ERC20)[1].implementation == erc20Impl);
        assert(TokenFactory(tokenFactory).getApprovedImplementations(TokenFactoryStorage.TokenStandard.ERC721)[1].implementation == erc721Impl);
        assert(TokenFactory(tokenFactory).getApprovedImplementations(TokenFactoryStorage.TokenStandard.ERC1155)[1].implementation == erc1155Impl);

        vm.stopBroadcast();
    }
}