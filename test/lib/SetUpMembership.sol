// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Renderer} from "src/lib/renderer/Renderer.sol";
import {MembershipBeacon} from "src/lib/beacon/MembershipBeacon.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {Helpers} from "test/lib/Helpers.sol";

abstract contract SetUpMembership is Helpers {
    address public owner;
    address public paymentCollector;
    Renderer public rendererImpl;
    MembershipBeacon public membershipBeacon;
    Membership public membershipImpl;
    MembershipFactory public membershipFactory;

    function setUp() public virtual {
        owner = createAccount(); // creates a soulbound account, i.e. creates a 6551 wallet attached to an ERC721
        paymentCollector = createAccount();
        rendererImpl = new Renderer(owner, "https://members.station.express");
        membershipImpl = new Membership();
        membershipBeacon = new MembershipBeacon();
        membershipFactory = new MembershipFactory();

        // Initialize the Beacon with the given implementation
        membershipBeacon.initialize(owner, address(membershipImpl));
        // Initialize the Factory with the given beacon
        membershipFactory.initialize(owner, address(membershipBeacon));
    }

    function create() public returns (Membership proxy) {
        proxy = Membership(membershipFactory.createWithBeacon(owner, address(rendererImpl), "Test", "TEST"));
    }
}
