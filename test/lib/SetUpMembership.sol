// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {Helpers} from "test/lib/Helpers.sol";

abstract contract SetUpMembership is Helpers {
    address public owner;
    address public paymentCollector;
    address public rendererImpl;
    Membership public membershipImpl;
    MembershipFactory public membershipFactory;

    function setUp() public virtual {
        owner = createAccount();
        paymentCollector = createAccount();
        rendererImpl = address(new Renderer(owner, "https://members.station.express"));
        membershipImpl = new Membership();
        membershipFactory = new MembershipFactory(address(membershipImpl), owner);
    }

    function create() public returns (Membership proxy) {
        proxy = Membership(membershipFactory.create(owner, rendererImpl, paymentCollector, "Test", "TEST"));
    }
}
