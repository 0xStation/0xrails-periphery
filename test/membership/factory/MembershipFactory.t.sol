// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC1967} from "lib/openzeppelin-contracts/contracts/interfaces/IERC1967.sol";
import {MembershipFactory} from "src/membership/factory/MembershipFactory.sol";
import {IMembershipFactory} from "src/membership/factory/IMembershipFactory.sol";
import {ERC721Mage} from "mage/cores/ERC721/ERC721Mage.sol";
import {IInitializableInternal} from "mage/lib/initializable/IInitializable.sol";
import {IOwnable} from "mage/access/ownable/interface/IOwnable.sol";

contract MembershipFactoryTest is Test, IERC1967 {

    ERC721Mage public erc721MageImpl;
    ERC721Mage public erc721MageProxy; // ERC1967 proxy wrapped in ERC721Mage for convenience
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
        erc721MageImpl = new ERC721Mage();

        // deploy membership proxy manually for testing
        owner = address(0xbeefEbabe);
        name = "Station";
        symbol = "STN";
        // include empty init data for setup
        initData = abi.encodeWithSelector(
            ERC721Mage.initialize.selector,
            owner,
            name,
            symbol,
            ''
        );
        erc721MageProxy = ERC721Mage(payable(address(new ERC1967Proxy(
            address(erc721MageImpl), 
            initData
        ))));

        membershipFactoryImpl = new MembershipFactory();
        membershipFactoryProxy = MembershipFactory(address(new ERC1967Proxy(address(membershipFactoryImpl), '')));
    }

    function test_setUp() public {
        // assert erc721 impl values
        assertTrue(erc721MageImpl.initialized());
        assertEq(erc721MageImpl.owner(), address(0x0));
        assertEq(erc721MageImpl.name(), '');
        assertEq(erc721MageImpl.symbol(), '');

        // assert erc721 proxy values
        assertTrue(erc721MageProxy.initialized());
        assertEq(erc721MageProxy.owner(), owner);
        assertEq(erc721MageProxy.name(), name);
        assertEq(erc721MageProxy.symbol(), symbol);

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

        membershipFactoryProxy.initialize(address(erc721MageImpl), owner);
        
        assertTrue(membershipFactoryProxy.initialized());
        assertEq(membershipFactoryProxy.owner(), owner);
        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721MageImpl));
    }

    function test_initializeRevertAlreadyInitialized() public {
        membershipFactoryProxy.initialize(address(erc721MageImpl), owner);
        
        assertTrue(membershipFactoryProxy.initialized());
        assertEq(membershipFactoryProxy.owner(), owner);
        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721MageImpl));

        // attempt re initialization
        err = abi.encodeWithSelector(IInitializableInternal.AlreadyInitialized.selector);
        vm.expectRevert(err);
        membershipFactoryProxy.initialize(address(erc721MageImpl), owner);
    }

    function test_initializeRevertInvalidImplementation() public {
        assertFalse(membershipFactoryProxy.initialized());

        err = abi.encodeWithSelector(IMembershipFactory.InvalidImplementation.selector);
        vm.expectRevert(err);
        membershipFactoryProxy.initialize(address(0x0), owner);

        assertFalse(membershipFactoryProxy.initialized());
    }

    function test_setMembershipImpl() public {
        membershipFactoryProxy.initialize(address(erc721MageImpl), owner);

        // upgrade to new membership implementation
        ERC721Mage newERC721MageImpl = new ERC721Mage();
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(newERC721MageImpl));
        erc721MageProxy.upgradeTo(address(newERC721MageImpl));

        // assert upgrade was performed successfully
        bytes32 implementationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address storedImpl = address(uint160(uint256(vm.load(address(erc721MageProxy), implementationSlot))));
        assertEq(storedImpl, address(newERC721MageImpl));

        membershipFactoryProxy.setMembershipImpl(address(newERC721MageImpl));

        assertEq(membershipFactoryProxy.membershipImpl(), address(newERC721MageImpl));
    }

    function test_authorizeUpgrade(address notOwner) public {
        vm.assume(notOwner != owner);
        membershipFactoryProxy.initialize(address(erc721MageImpl), owner);

        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721MageImpl));
        
        // attempt upgrade to new membership implementation as not owner
        ERC721Mage newERC721MageImpl = new ERC721Mage();
        vm.expectRevert();
        vm.prank(notOwner);
        membershipFactoryProxy.setMembershipImpl(address(newERC721MageImpl));

        // assert implementation unchanged
        assertEq(membershipFactoryProxy.membershipImpl(), address(erc721MageImpl));
    }

    function test_create(
        address newOwner,
        string memory newName,
        string memory newSymbol
    ) public {
        vm.assume(newOwner != address(0x0));
        membershipFactoryProxy.initialize(address(erc721MageImpl), owner);

        address oldMembership = address(erc721MageProxy);
        ERC721Mage newMembership = ERC721Mage(payable(membershipFactoryProxy.create(newOwner, newName, newSymbol, '')));
        assertFalse(oldMembership == address(newMembership));
        assertEq(newMembership.owner(), newOwner);
        assertEq(newMembership.name(), newName);
        assertEq(newMembership.symbol(), newSymbol);
    }
}
  