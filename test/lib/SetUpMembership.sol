// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {MembershipFactory} from "src/membership/factory/MembershipFactory.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {Helpers} from "test/lib/Helpers.sol";

abstract contract SetUpMembership is Helpers {
    address public owner;
    address public payoutAddress;
    ERC721Rails public membershipImpl;
    MembershipFactory public membershipFactoryImpl;
    MembershipFactory public membershipFactory;
    PayoutAddressExtension public payoutAddressExtension;
    address public metadataRouter = address(0);

    function setUp() public virtual {
        owner = createAccount();
        payoutAddress = createAccount();
        membershipImpl = new ERC721Rails();
        membershipFactoryImpl = new MembershipFactory();
        membershipFactory = MembershipFactory(address(new ERC1967Proxy(address(membershipFactoryImpl), bytes(""))));
        membershipFactory.initialize(address(membershipImpl), owner);
        payoutAddressExtension = new PayoutAddressExtension(address(0));
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

        proxy = ERC721Rails(payable(membershipFactory.create(owner, "Test", "TEST", initData)));
    }
}
