// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC1967} from "lib/openzeppelin-contracts/contracts/interfaces/IERC1967.sol";
import {MembershipFactory} from "src/membership/factory/MembershipFactory.sol";
import {IMembershipFactory} from "src/membership/factory/IMembershipFactory.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IInitializableInternal} from "0xrails/lib/initializable/IInitializable.sol";
import {IOwnable} from "0xrails/access/ownable/interface/IOwnable.sol";

contract MembershipFactoryTest is Test, IERC1967 {

    ERC721Rails public erc721RailsImpl;
    ERC721Rails public erc721RailsProxy; // ERC1967 proxy wrapped in ERC721Rails for convenience
    MembershipFactory public membershipFactoryImpl;
    MembershipFactory public membershipFactoryProxy; // ERC1967 proxy wrapped in MembershipFactory for convenience

    address owner;
    string public name;
    string public symbol;
    bytes public initData;

    // intended to contain custom error signatures
    bytes public err;

    function setUp() public {
        // deploy membership implementation
        erc721RailsImpl = new ERC721Rails();

        // deploy membership proxy manually for testing
        owner = address(0xbeefEbabe);
        name = "Station";
        symbol = "STN";
        // include empty init data for setup
        initData = abi.encodeWithSelector(
            ERC721Rails.initialize.selector,
            owner,
            name,
            symbol,
            ''
        );
        erc721RailsProxy = ERC721Rails(payable(address(new ERC1967Proxy(
            address(erc721RailsImpl), 
            initData
        ))));

        membershipFactoryImpl = new MembershipFactory();
        membershipFactoryProxy = MembershipFactory(address(new ERC1967Proxy(address(membershipFactoryImpl), '')));
    }

    function test_setUp() public {
        // assert erc721 impl values
        assertTrue(erc721RailsImpl.initialized());
        assertEq(erc721RailsImpl.owner(), address(0x0));
        assertEq(erc721RailsImpl.name(), '');
        assertEq(erc721RailsImpl.symbol(), '');

        // assert erc721 proxy values
        assertTrue(erc721RailsProxy.initialized());
        assertEq(erc721RailsProxy.owner(), owner);
        assertEq(erc721RailsProxy.name(), name);
        assertEq(erc721RailsProxy.symbol(), symbol);

        // factory implementation sets isInitialized to `true` via _disableInitializers()
        assertTrue(membershipFactoryImpl.initialized());
        // factory proxy not yet initialized
        assertFalse(membershipFactoryProxy.initialized());

        // assert no factory initializations made yet
        assertEq(membershipFactoryImpl.owner(), address(0x0));
        assertEq(membershipFactoryImpl.membershipImpl(), address(0x0));
        assertEq(membershipFactoryProxy.owner(), address(0x0));
        assertEq(membershipFactoryProxy.membershipImpl(), address(0x0));
    }

    function test_initialize() public {
        assertFalse(membershipFactoryProxy.initialized());

        membershipFactoryProxy.initialize(address(erc721RailsImpl), owner);
        
        assertTrue(membershipFactoryProxy.initialized());
        assertEq(membershipFactoryProxy.owner(), owner);
        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721RailsImpl));
    }

    function test_initializeRevertAlreadyInitialized() public {
        membershipFactoryProxy.initialize(address(erc721RailsImpl), owner);
        
        assertTrue(membershipFactoryProxy.initialized());
        assertEq(membershipFactoryProxy.owner(), owner);
        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721RailsImpl));

        // attempt re initialization
        err = abi.encodeWithSelector(IInitializableInternal.AlreadyInitialized.selector);
        vm.expectRevert(err);
        membershipFactoryProxy.initialize(address(erc721RailsImpl), owner);
    }

    function test_initializeRevertInvalidImplementation() public {
        assertFalse(membershipFactoryProxy.initialized());

        err = abi.encodeWithSelector(IMembershipFactory.InvalidImplementation.selector);
        vm.expectRevert(err);
        membershipFactoryProxy.initialize(address(0x0), owner);

        assertFalse(membershipFactoryProxy.initialized());
    }

    function test_setMembershipImpl() public {
        membershipFactoryProxy.initialize(address(erc721RailsImpl), owner);

        // upgrade to new membership implementation
        ERC721Rails newERC721RailsImpl = new ERC721Rails();
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(newERC721RailsImpl));
        erc721RailsProxy.upgradeTo(address(newERC721RailsImpl));

        // assert upgrade was performed successfully
        bytes32 implementationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address storedImpl = address(uint160(uint256(vm.load(address(erc721RailsProxy), implementationSlot))));
        assertEq(storedImpl, address(newERC721RailsImpl));

        membershipFactoryProxy.setMembershipImpl(address(newERC721RailsImpl));

        assertEq(membershipFactoryProxy.membershipImpl(), address(newERC721RailsImpl));
    }

    function test_authorizeUpgrade(address notOwner) public {
        vm.assume(notOwner != owner);
        membershipFactoryProxy.initialize(address(erc721RailsImpl), owner);

        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721RailsImpl));
        
        // attempt upgrade to new membership implementation as not owner
        ERC721Rails newERC721RailsImpl = new ERC721Rails();
        vm.expectRevert();
        vm.prank(notOwner);
        membershipFactoryProxy.setMembershipImpl(address(newERC721RailsImpl));

        // assert implementation unchanged
        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721RailsImpl));
    }

    function test_create(
        address newOwner,
        string memory newName,
        string memory newSymbol
    ) public {
        vm.assume(newOwner != address(0x0));
        membershipFactoryProxy.initialize(address(erc721RailsImpl), owner);

        address oldMembership = address(erc721RailsProxy);
        ERC721Rails newMembership = ERC721Rails(payable(membershipFactoryProxy.create(newOwner, newName, newSymbol, '')));
        assertFalse(oldMembership == address(newMembership));
        assertEq(newMembership.owner(), newOwner);
        assertEq(newMembership.name(), newName);
        assertEq(newMembership.symbol(), newSymbol);
    }

    function test_rejectUnrecognizedCalls() public {
        (bool r,) = address(membershipFactoryProxy).call{ value: 1}('');
        vm.expectRevert();
        require(r);
        (bool s,) = address(membershipFactoryProxy).call(hex'deadbeef');
        vm.expectRevert();
        require(s);
    }
}
  