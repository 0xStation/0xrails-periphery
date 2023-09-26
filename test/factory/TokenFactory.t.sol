// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC1967} from "lib/openzeppelin-contracts/contracts/interfaces/IERC1967.sol";
import {TokenFactory} from "src/factory/TokenFactory.sol";
import {ITokenFactory} from "src/factory/ITokenFactory.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {ERC20Rails} from "0xrails/cores/ERC20/ERC20Rails.sol";
import {ERC1155Rails} from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {IInitializableInternal} from "0xrails/lib/initializable/IInitializable.sol";
import {IOwnable} from "0xrails/access/ownable/interface/IOwnable.sol";

contract TokenFactoryTest is Test, IERC1967 {
    ERC721Rails public erc721RailsImpl;
    ERC721Rails public erc721RailsProxy; // ERC1967 proxy wrapped in ERC721Rails for convenience
    ERC20Rails public erc20RailsImpl;
    ERC20Rails public erc20RailsProxy; // ERC1967 proxy wrapped in ERC20Rails for convenience
    ERC1155Rails public erc1155RailsImpl;
    ERC1155Rails public erc1155RailsProxy; // ERC1967 proxy wrapped in ERC1155Rails for convenience
    TokenFactory public tokenFactoryImpl;
    TokenFactory public tokenFactoryProxy; // ERC1967 proxy wrapped in TokenFactory for convenience

    address owner;
    string public name;
    string public symbol;
    bytes public initData;

    // intended to contain custom error signatures
    bytes public err;

    function setUp() public {
        // deploy membership implementation
        erc721RailsImpl = new ERC721Rails();
        // deploy points implementation
        erc20RailsImpl = new ERC20Rails();
        // deploy badge implementation
        erc1155RailsImpl = new ERC1155Rails();

        // configure testing initData for all Rails contracts
        owner = address(0xbeefEbabe);
        name = "Station";
        symbol = "STN";
        // include empty init data for setup
        initData = abi.encodeWithSelector(ERC721Rails.initialize.selector, owner, name, symbol, "");

        // deploy membership proxy manually for testing
        erc721RailsProxy = ERC721Rails(
            payable(
                address(
                    new ERC1967Proxy(
                    address(erc721RailsImpl), 
                    initData
                    )
                )
            )
        );
        erc20RailsProxy = ERC20Rails(
            payable(
                address(
                    new ERC1967Proxy(
                    address(erc20RailsImpl), 
                    initData
                    )
                )
            )
        );
        erc1155RailsProxy = ERC1155Rails(
            payable(
                address(
                    new ERC1967Proxy(
                    address(erc1155RailsImpl), 
                    initData
                    )
                )
            )
        );

        tokenFactoryImpl = new TokenFactory();
        tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
    }

    function test_setUp() public {
        // assert erc721 impl values
        assertTrue(erc721RailsImpl.initialized());
        assertEq(erc721RailsImpl.owner(), address(0x0));
        assertEq(erc721RailsImpl.name(), "");
        assertEq(erc721RailsImpl.symbol(), "");

        // assert erc721 proxy values
        assertTrue(erc721RailsProxy.initialized());
        assertEq(erc721RailsProxy.owner(), owner);
        assertEq(erc721RailsProxy.name(), name);
        assertEq(erc721RailsProxy.symbol(), symbol);

        // assert erc20 impl values
        assertTrue(erc20RailsImpl.initialized());
        assertEq(erc20RailsImpl.owner(), address(0x0));
        assertEq(erc20RailsImpl.name(), "");
        assertEq(erc20RailsImpl.symbol(), "");

        // assert erc20 proxy values
        assertTrue(erc20RailsProxy.initialized());
        assertEq(erc20RailsProxy.owner(), owner);
        assertEq(erc20RailsProxy.name(), name);
        assertEq(erc20RailsProxy.symbol(), symbol);

        // assert erc1155 impl values
        assertTrue(erc1155RailsImpl.initialized());
        assertEq(erc1155RailsImpl.owner(), address(0x0));
        assertEq(erc1155RailsImpl.name(), "");
        assertEq(erc1155RailsImpl.symbol(), "");

        // assert erc1155 proxy values
        assertTrue(erc1155RailsProxy.initialized());
        assertEq(erc1155RailsProxy.owner(), owner);
        assertEq(erc1155RailsProxy.name(), name);
        assertEq(erc1155RailsProxy.symbol(), symbol);

        // factory implementation sets isInitialized to `true` via _disableInitializers()
        assertTrue(tokenFactoryImpl.initialized());
        // factory proxy not yet initialized
        assertFalse(tokenFactoryProxy.initialized());

        // assert no factory initializations made yet
        assertEq(tokenFactoryImpl.owner(), address(0x0));
        assertEq(tokenFactoryImpl.membershipImpl(), address(0x0));
        assertEq(tokenFactoryImpl.pointsImpl(), address(0x0));
        assertEq(tokenFactoryImpl.badgesImpl(), address(0x0));
        assertEq(tokenFactoryProxy.owner(), address(0x0));
        assertEq(tokenFactoryProxy.membershipImpl(), address(0x0));
        assertEq(tokenFactoryProxy.pointsImpl(), address(0x0));
        assertEq(tokenFactoryProxy.badgesImpl(), address(0x0));
    }

    function test_initialize() public {
        assertFalse(tokenFactoryProxy.initialized());

        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        assertTrue(tokenFactoryProxy.initialized());
        assertEq(tokenFactoryProxy.owner(), owner);
        assertEq(tokenFactoryProxy.membershipImpl(), address(erc721RailsImpl));
        assertEq(tokenFactoryProxy.pointsImpl(), address(erc20RailsImpl));
        assertEq(tokenFactoryProxy.badgesImpl(), address(erc1155RailsImpl));
    }

    function test_initializeRevertAlreadyInitialized() public {
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        assertTrue(tokenFactoryProxy.initialized());
        assertEq(tokenFactoryProxy.owner(), owner);
        assertEq(tokenFactoryProxy.membershipImpl(), address(erc721RailsImpl));
        assertEq(tokenFactoryProxy.pointsImpl(), address(erc20RailsImpl));
        assertEq(tokenFactoryProxy.badgesImpl(), address(erc1155RailsImpl));

        // attempt re initialization
        err = abi.encodeWithSelector(IInitializableInternal.AlreadyInitialized.selector);
        vm.expectRevert(err);
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);
    }

    function test_initializeRevertInvalidImplementation() public {
        assertFalse(tokenFactoryProxy.initialized());

        err = abi.encodeWithSelector(ITokenFactory.InvalidImplementation.selector);
        vm.expectRevert(err);
        tokenFactoryProxy.initialize(address(0x0), address(0x0), address(0x0), owner);

        assertFalse(tokenFactoryProxy.initialized());
    }

    function test_setMembershipImpl() public {
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

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

        tokenFactoryProxy.setMembershipImpl(address(newERC721RailsImpl));

        assertEq(tokenFactoryProxy.membershipImpl(), address(newERC721RailsImpl));
    }

    function test_setPointsImpl() public {
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        // upgrade to new points implementation
        ERC20Rails newERC20RailsImpl = new ERC20Rails();
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(newERC20RailsImpl));
        erc20RailsProxy.upgradeTo(address(newERC20RailsImpl));

        // assert upgrade was performed successfully
        bytes32 implementationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address storedImpl = address(uint160(uint256(vm.load(address(erc20RailsProxy), implementationSlot))));
        assertEq(storedImpl, address(newERC20RailsImpl));

        tokenFactoryProxy.setMembershipImpl(address(newERC20RailsImpl));

        assertEq(tokenFactoryProxy.membershipImpl(), address(newERC20RailsImpl));
    }

    function test_setBadgesImpl() public {
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        // upgrade to new badges implementation
        ERC1155Rails newERC1155RailsImpl = new ERC1155Rails();
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(newERC1155RailsImpl));
        erc1155RailsProxy.upgradeTo(address(newERC1155RailsImpl));

        // assert upgrade was performed successfully
        bytes32 implementationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        address storedImpl = address(uint160(uint256(vm.load(address(erc1155RailsProxy), implementationSlot))));
        assertEq(storedImpl, address(newERC1155RailsImpl));

        tokenFactoryProxy.setMembershipImpl(address(newERC1155RailsImpl));

        assertEq(tokenFactoryProxy.membershipImpl(), address(newERC1155RailsImpl));
    }

    function test_authorizeUpgrade(address notOwner) public {
        vm.assume(notOwner != owner);
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        assertEq(tokenFactoryProxy.membershipImpl(), address(erc721RailsImpl));

        // attempt upgrade to new membership implementation as not owner
        ERC721Rails newERC721RailsImpl = new ERC721Rails();
        vm.expectRevert();
        vm.prank(notOwner);
        tokenFactoryProxy.setMembershipImpl(address(newERC721RailsImpl));

        // assert implementation unchanged
        assertEq(tokenFactoryProxy.membershipImpl(), address(erc721RailsImpl));
    }

    function test_createMembership(address newOwner, string memory newName, string memory newSymbol) public {
        vm.assume(newOwner != address(0x0));
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        address oldMembership = address(erc721RailsProxy);
        ERC721Rails newMembership =
            ERC721Rails(payable(tokenFactoryProxy.createMembership(newOwner, newName, newSymbol, "")));
        assertFalse(oldMembership == address(newMembership));
        assertEq(newMembership.owner(), newOwner);
        assertEq(newMembership.name(), newName);
        assertEq(newMembership.symbol(), newSymbol);
    }

    function test_createPoints(address newOwner, string memory newName, string memory newSymbol) public {
        vm.assume(newOwner != address(0x0));
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        address oldPoints = address(erc20RailsProxy);
        ERC20Rails newPoints =
            ERC20Rails(payable(tokenFactoryProxy.createPoints(newOwner, newName, newSymbol, "")));
        assertFalse(oldPoints == address(newPoints));
        assertEq(newPoints.owner(), newOwner);
        assertEq(newPoints.name(), newName);
        assertEq(newPoints.symbol(), newSymbol);
    }

    function test_createBadges(address newOwner, string memory newName, string memory newSymbol) public {
        vm.assume(newOwner != address(0x0));
        tokenFactoryProxy.initialize(address(erc721RailsImpl), address(erc20RailsImpl), address(erc1155RailsImpl), owner);

        address oldBadges = address(erc1155RailsProxy);
        ERC1155Rails newBadges =
            ERC1155Rails(payable(tokenFactoryProxy.createBadges(newOwner, newName, newSymbol, "")));
        assertFalse(oldBadges == address(newBadges));
        assertEq(newBadges.owner(), newOwner);
        assertEq(newBadges.name(), newName);
        assertEq(newBadges.symbol(), newSymbol);
    }

    function test_rejectUnrecognizedCalls() public {
        (bool r,) = address(tokenFactoryProxy).call{value: 1}("");
        vm.expectRevert();
        require(r);
        (bool s,) = address(tokenFactoryProxy).call(hex"deadbeef");
        vm.expectRevert();
        require(s);
    }
}
