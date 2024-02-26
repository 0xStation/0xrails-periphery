// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155Rails} from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {TokenFactory} from "src/factory/TokenFactory.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {Helpers} from "test/lib/Helpers.sol";

abstract contract SetUpERC1155Rails is Helpers {
    address public owner;
    address public payoutAddress;
    bytes32 public inputSalt = bytes32(0);
    ERC1155Rails public erc1155Impl;
    TokenFactory public tokenFactoryImpl;
    TokenFactory public tokenFactory;
    PayoutAddressExtension public payoutAddressExtension;

    function setUp() public virtual {
        owner = createAccount();
        payoutAddress = createAccount();
        erc1155Impl = new ERC1155Rails();
        tokenFactoryImpl = new TokenFactory();
        tokenFactory = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), bytes(""))));
        tokenFactory.initialize(owner, address(0x0), address(0x0), address(erc1155Impl), address(0x0));
        payoutAddressExtension = new PayoutAddressExtension();
    }

    function create() public returns (ERC1155Rails proxy) {
        proxy = ERC1155Rails(
            payable(
                tokenFactory.createERC1155(payable(address(erc1155Impl)), inputSalt, owner, "Test", "TEST", bytes(""))
            )
        );
    }
}
