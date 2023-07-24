// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Renderer} from "src/lib/renderer/Renderer.sol";
import {Membership} from "src/membership/Membership.sol";
import {MembershipFactory} from "src/membership/MembershipFactory.sol";
import {MembershipBeacon} from "src/lib/beacon/MembershipBeacon.sol";
import {MembershipBeaconProxy} from "src/lib/beacon/MembershipBeaconProxy.sol";
import {Permissions} from "src/lib/Permissions.sol";

contract BeaconProxyTest is Test {
    address public minter = address(1);
    address public owner = address(2);
    address public maintainer = address(56);
    address public paymentReciever = address(456);

    MembershipFactory public membershipFactory;
    MembershipBeacon public membershipBeacon;
    Renderer public rendererImpl;
    Membership public membershipImpl;
    Membership public membershipImpl2;

    function setUp() public {
        rendererImpl = new Renderer(msg.sender, "https://tokens.station.express");
        membershipImpl = new Membership();
        membershipImpl2 = new Membership();
        membershipBeacon = new MembershipBeacon();
        membershipFactory = new MembershipFactory();

        membershipBeacon.initialize(owner, address(membershipImpl));
        membershipFactory.initialize(owner, address(membershipBeacon));
    }

    function test_switching_beacon_impl_by_owner() public {
        startHoax(owner);
        assertEq(membershipBeacon.implementation(), address(membershipImpl));

        membershipBeacon.upgradeTo(address(membershipImpl2));
        assertEq(membershipBeacon.implementation(), address(membershipImpl2));
        vm.stopPrank();
    }

    function test_switching_beacon_impl_with_upgrade_permission() public {
        startHoax(owner);
        Permissions.Operation [] memory operations = new Permissions.Operation[](1);
        operations[0] = Permissions.Operation.UPGRADE; 
        bytes32 permissions = membershipBeacon.permissionsValue(operations);
        membershipBeacon.permit(maintainer, permissions);
        assert(membershipBeacon.hasPermission(maintainer, Permissions.Operation.UPGRADE));
        vm.stopPrank();

        startHoax(maintainer);
        membershipBeacon.upgradeTo(address(membershipImpl2));
        assertEq(membershipBeacon.implementation(), address(membershipImpl2));
        vm.stopPrank();
    }

    function test_switching_beacon_impl_without_losing_data() public {
        startHoax(owner);
        address membership =
            membershipFactory.createWithBeacon(msg.sender, address(rendererImpl), "Friends of Station", "FRIENDS");
        membershipBeacon.upgradeTo(address(membershipImpl2));
        Membership membershipContract = Membership(membership);

        assertEq(membershipContract.owner(), msg.sender);
        assertEq(membershipContract.renderer(), address(rendererImpl));
        assertEq(membershipContract.name(), "Friends of Station");
        assertEq(membershipContract.symbol(), "FRIENDS");
        vm.stopPrank();
    }

    function test_turning_off_beacon_by_maintainer() public {
        startHoax(owner);
        address membership =
            membershipFactory.createWithBeacon(maintainer, address(rendererImpl), "Friends of Station", "FRIENDS");
        vm.stopPrank();

        startHoax(maintainer);
        assertEq(MembershipBeaconProxy(membership).implementation(), address(membershipImpl));
        MembershipBeaconProxy(membership).addCustomImplementation(address(membershipImpl2));
        assertEq(MembershipBeaconProxy(membership).implementation(), address(membershipImpl2));
        vm.stopPrank();
    }
}
