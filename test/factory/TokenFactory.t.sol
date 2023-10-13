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
        assertEq(tokenFactoryProxy.owner(), address(0x0));
    }

    function test_initialize() public {
        assertFalse(tokenFactoryProxy.initialized());

        tokenFactoryProxy.initialize(owner);

        assertTrue(tokenFactoryProxy.initialized());
        assertEq(tokenFactoryProxy.owner(), owner);
    }

    function test_initializeRevertAlreadyInitialized() public {
        tokenFactoryProxy.initialize(owner);

        assertTrue(tokenFactoryProxy.initialized());
        assertEq(tokenFactoryProxy.owner(), owner);

        // attempt re initialization
        err = abi.encodeWithSelector(IInitializableInternal.AlreadyInitialized.selector);
        vm.expectRevert(err);
        tokenFactoryProxy.initialize(owner);
    }

    function test_authorizeUpgrade(address notOwner) public {
        vm.assume(notOwner != owner);
        tokenFactoryProxy.initialize(owner);

        // attempt upgrade to new membership implementation as not owner
        ERC721Rails newERC721RailsImpl = new ERC721Rails();
        vm.expectRevert();
        vm.prank(notOwner);
        tokenFactoryProxy.upgradeTo(address(newERC721RailsImpl));
    }

    function test_createMembership(address newOwner, string memory newName, string memory newSymbol) public {
        vm.assume(newOwner != address(0x0));
        tokenFactoryProxy.initialize(owner);

        address oldMembership = address(erc721RailsProxy);
        ERC721Rails newMembership = ERC721Rails(
            payable(tokenFactoryProxy.createERC721(payable(address(erc721RailsImpl)), newOwner, newName, newSymbol, ""))
        );
        assertFalse(oldMembership == address(newMembership));
        assertEq(newMembership.owner(), newOwner);
        assertEq(newMembership.name(), newName);
        assertEq(newMembership.symbol(), newSymbol);
    }

    function test_createPoints(address newOwner, string memory newName, string memory newSymbol) public {
        vm.assume(newOwner != address(0x0));
        tokenFactoryProxy.initialize(owner);

        address oldPoints = address(erc20RailsProxy);
        ERC20Rails newPoints = ERC20Rails(
            payable(tokenFactoryProxy.createERC20(payable(address(erc20RailsImpl)), newOwner, newName, newSymbol, ""))
        );
        assertFalse(oldPoints == address(newPoints));
        assertEq(newPoints.owner(), newOwner);
        assertEq(newPoints.name(), newName);
        assertEq(newPoints.symbol(), newSymbol);
    }

    function test_createBadges(address newOwner, string memory newName, string memory newSymbol) public {
        vm.assume(newOwner != address(0x0));
        tokenFactoryProxy.initialize(owner);

        address oldBadges = address(erc1155RailsProxy);
        ERC1155Rails newBadges = ERC1155Rails(
            payable(
                tokenFactoryProxy.createERC1155(payable(address(erc1155RailsImpl)), newOwner, newName, newSymbol, "")
            )
        );
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
