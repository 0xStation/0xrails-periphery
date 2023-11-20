// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {TokenFactory} from "src/factory/TokenFactory.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {Helpers} from "test/lib/Helpers.sol";

abstract contract SetUpMembership is Helpers {
    address public owner;
    address public payoutAddress;
    bytes32 public inputSalt = bytes32(0);
    ERC721Rails public membershipImpl;
    TokenFactory public membershipFactoryImpl;
    TokenFactory public membershipFactory;
    PayoutAddressExtension public payoutAddressExtension;

    function setUp() public virtual {
        owner = createAccount();
        payoutAddress = createAccount();
        membershipImpl = new ERC721Rails();
        membershipFactoryImpl = new TokenFactory();
        membershipFactory = TokenFactory(address(new ERC1967Proxy(address(membershipFactoryImpl), bytes(""))));
        membershipFactory.initialize(owner, address(0x0), address(membershipImpl), address(0x0));
        payoutAddressExtension = new PayoutAddressExtension();
    }

    function create() public returns (ERC721Rails proxy) {
        // add payout address extension to proxy, to be replaced with extension beacon
        bytes memory addPayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector, IPayoutAddress.payoutAddress.selector, address(payoutAddressExtension)
        );
        bytes memory addUpdatePayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.updatePayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addRemovePayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.setExtension.selector,
            IPayoutAddress.removePayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes[] memory calls = new bytes[](3);
        calls[0] = addPayoutAddressExtension;
        calls[1] = addUpdatePayoutAddressExtension;
        calls[2] = addRemovePayoutAddressExtension;
        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, calls);

        proxy = ERC721Rails(
            payable(membershipFactory.createERC721(payable(address(membershipImpl)), inputSalt, owner, "Test", "TEST", initData))
        );
    }
}
