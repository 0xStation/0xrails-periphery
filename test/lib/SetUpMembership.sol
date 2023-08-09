// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721Mage} from "mage/cores/ERC721/ERC721Mage.sol";
import {IExtensionsExternal as IExtensions} from "mage/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";

import {MembershipFactory} from "src/v2/membership/MembershipFactory.sol";
import {PayoutAddressExtension} from "src/v2/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {
    IPayoutAddressExtensionInternal,
    IPayoutAddressExtensionExternal
} from "src/v2/membership/extensions/PayoutAddress/IPayoutAddressExtension.sol";
import {Helpers} from "test/lib/Helpers.sol";

abstract contract SetUpMembership is Helpers {
    address public owner;
    address public payoutAddress;
    ERC721Mage public membershipImpl;
    MembershipFactory public membershipFactory;
    PayoutAddressExtension public payoutAddressExtension;

    function setUp() public virtual {
        owner = createAccount();
        payoutAddress = createAccount();
        membershipImpl = new ERC721Mage();
        membershipFactory = new MembershipFactory();
        membershipFactory.initialize(address(membershipImpl), owner);
        payoutAddressExtension = new PayoutAddressExtension(address(0));
    }

    function create() public returns (ERC721Mage proxy) {
        // add payout address extension to proxy, to be replaced with extension beacon
        bytes memory addPayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.addExtension.selector,
            IPayoutAddressExtensionInternal.payoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes memory addUpdatePayoutAddressExtension = abi.encodeWithSelector(
            IExtensions.addExtension.selector,
            IPayoutAddressExtensionExternal.updatePayoutAddress.selector,
            address(payoutAddressExtension)
        );
        bytes[] memory calls = new bytes[](2);
        calls[0] = addPayoutAddressExtension;
        calls[1] = addUpdatePayoutAddressExtension;
        bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, calls);

        proxy = ERC721Mage(payable(membershipFactory.create(owner, "Test", "TEST", initData)));
    }
}
