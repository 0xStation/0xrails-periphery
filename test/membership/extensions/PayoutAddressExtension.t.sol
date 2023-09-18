// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MockAccountDeployer} from "lib/0xrails/test/lib/MockAccount.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {ERC721Rails} from "0xrails/cores/ERC721/ERC721Rails.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {PayoutAddress} from "src/membership/extensions/PayoutAddress/PayoutAddress.sol";
import {IPayoutAddress} from "src/membership/extensions/PayoutAddress/IPayoutAddress.sol";
import {MetadataRouter} from "src/metadataRouter/MetadataRouter.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PayoutAddressExtensionTest is Test, MockAccountDeployer, ERC721Rails {
    PayoutAddressExtension public payoutAddressExtension;
    MetadataRouter public exampleRouterImpl;
    MetadataRouter public exampleRouterProxy;

    address public owner_;
    address public initialPayoutAddress;
    string public someRoute;
    string public defaultURI;
    string public someURI;
    string[] public routes;
    string[] public uris;
    bytes public initData;
    bytes public payoutAddressCall;
    bytes public getAllSelectorsCall;

    // to store expected revert errors
    bytes err;

    function setUp() public {
        owner_ = vm.addr(0xbeefEEbabe);
        someRoute = "token";
        routes = new string[](1);
        routes[0] = someRoute;
        defaultURI = "default";
        someURI = "someURI";
        uris = new string[](1);
        uris[0] = someURI;
        initData = abi.encodeWithSelector(MetadataRouter.initialize.selector, owner_, defaultURI, routes, uris);

        exampleRouterImpl = new MetadataRouter();
        exampleRouterProxy = MetadataRouter(address(new ERC1967Proxy(address(exampleRouterImpl), initData)));

        // deploy payoutAddressExtension as `owner` so it grants `owner` ADMIN permission
        vm.prank(owner_);
        payoutAddressExtension = new PayoutAddressExtension(address(exampleRouterProxy));

        // ERC721Rails is just used to access the `Permissions::hasPermission()` method,
        // so no proxy is necessary in this test file- the impl will do
        _addPermission(Operations.ADMIN, owner_);

        // map extensions
        _setExtension(PayoutAddress.updatePayoutAddress.selector, address(payoutAddressExtension));
        _setExtension(PayoutAddress.removePayoutAddress.selector, address(payoutAddressExtension));
        _setExtension(PayoutAddress.payoutAddress.selector, address(payoutAddressExtension));
        _setExtension(PayoutAddressExtension.getAllSelectors.selector, address(payoutAddressExtension));
        _setExtension(PayoutAddressExtension.signatureOf.selector, address(payoutAddressExtension));

        // to be reused
        payoutAddressCall = abi.encodeWithSelector(PayoutAddress.payoutAddress.selector);
        getAllSelectorsCall = abi.encodeWithSelector(PayoutAddressExtension.getAllSelectors.selector);
    }

    function test_setUp() public {
        string memory returnedURI = exampleRouterProxy.routeURI(someRoute);
        string memory expectedURI = someURI;
        assertEq(returnedURI, expectedURI);

        string memory returnedDefault = exampleRouterProxy.defaultURI();
        string memory expectedDefault = defaultURI;
        assertEq(returnedDefault, expectedDefault);

        (, bytes memory ret) = address(this).call(payoutAddressCall);
        address returnedPayoutAddress = abi.decode(ret, (address));
        assertEq(returnedPayoutAddress, initialPayoutAddress);

        assertTrue(hasPermission(Operations.ADMIN, owner_));
        assertEq(getAllPermissions().length, 1);
    }

    function test_getAllSelectors() public {
        bytes4[] memory selectors;
        (, bytes memory ret) = address(this).call(getAllSelectorsCall);
        selectors = abi.decode(ret, (bytes4[]));
        assertEq(selectors.length, 3);
        assertEq(selectors[0], PayoutAddress.payoutAddress.selector);
        assertEq(selectors[1], PayoutAddress.updatePayoutAddress.selector);
        assertEq(selectors[2], PayoutAddress.removePayoutAddress.selector);
    }

    function test_signatureOf() public {
        bytes4[] memory selectors;
        (, bytes memory ret) = address(this).call(getAllSelectorsCall);
        selectors = abi.decode(ret, (bytes4[]));

        string memory returnedPayoutAddressSignature;
        (, bytes memory ret1) =
            address(this).call(abi.encodeWithSelector(PayoutAddressExtension.signatureOf.selector, selectors[0]));
        returnedPayoutAddressSignature = abi.decode(ret1, (string));
        string memory expectedPayoutAddressSignature = "payoutAddress()";
        assertEq(returnedPayoutAddressSignature, expectedPayoutAddressSignature);

        string memory updatePayoutSignature;
        (, bytes memory ret2) =
            address(this).call(abi.encodeWithSelector(PayoutAddressExtension.signatureOf.selector, selectors[1]));
        updatePayoutSignature = abi.decode(ret2, (string));
        string memory expectedUpdatePayoutSignature = "updatePayoutAddress(address)";
        assertEq(updatePayoutSignature, expectedUpdatePayoutSignature);

        string memory removePayoutSignature;
        (, bytes memory ret3) =
            address(this).call(abi.encodeWithSelector(PayoutAddressExtension.signatureOf.selector, selectors[2]));
        removePayoutSignature = abi.decode(ret3, (string));
        string memory expectedRemovePayoutSignature = "removePayoutAddress()";
        assertEq(removePayoutSignature, expectedRemovePayoutSignature);
    }

    function test_updatePayoutAddress() public {
        address oldPayoutAddress;
        (, bytes memory ret) = address(this).call(payoutAddressCall);
        oldPayoutAddress = abi.decode(ret, (address));
        address newPayoutAddress = createAccount();

        bytes memory updatePayoutCall =
            abi.encodeWithSelector(PayoutAddress.updatePayoutAddress.selector, newPayoutAddress);
        vm.prank(owner_);
        (bool r,) = address(this).call(updatePayoutCall);
        require(r);

        address updatedPayoutAddress;
        (, bytes memory ret2) = address(this).call(payoutAddressCall);
        updatedPayoutAddress = abi.decode(ret2, (address));
        assertEq(updatedPayoutAddress, newPayoutAddress);
        assertFalse(updatedPayoutAddress == oldPayoutAddress);
    }

    function test_updatePayoutAddressRevertOnlyOwner() public {
        address oldPayoutAddress;
        (, bytes memory ret) = address(this).call(payoutAddressCall);
        oldPayoutAddress = abi.decode(ret, (address));
        address newPayoutAddress = createAccount();

        // attempt to `updatePayoutAddress()` without pranking ADMIN
        bytes memory updatePayoutCall =
            abi.encodeWithSelector(PayoutAddress.updatePayoutAddress.selector, newPayoutAddress);
        (bool r,) = address(this).call(updatePayoutCall);
        vm.expectRevert();
        require(r);

        address updatedPayoutAddress;
        (, bytes memory ret2) = address(this).call(payoutAddressCall);
        updatedPayoutAddress = abi.decode(ret2, (address));
        assertEq(updatedPayoutAddress, oldPayoutAddress);
        assertFalse(updatedPayoutAddress == newPayoutAddress);
    }

    function test_updatePayoutAddressRevertPayoutAddressIsZero() public {
        address badPayoutAddress = address(0x0);

        // attempt to `updatePayoutAddress()` with `badPayoutAddress`
        bytes memory updatePayoutCall =
            abi.encodeWithSelector(PayoutAddress.updatePayoutAddress.selector, badPayoutAddress);
        (bool r,) = address(this).call(updatePayoutCall);
        vm.expectRevert();
        require(r);
    }

    function test_removePayoutAddress() public {
        address oldPayoutAddress;
        (, bytes memory ret) = address(this).call(payoutAddressCall);
        oldPayoutAddress = abi.decode(ret, (address));
        address newPayoutAddress = createAccount();

        // set payoutAddress
        bytes memory updatePayoutCall =
            abi.encodeWithSelector(PayoutAddress.updatePayoutAddress.selector, newPayoutAddress);
        vm.prank(owner_);
        (bool r,) = address(this).call(updatePayoutCall);
        require(r);

        address updatedPayoutAddress;
        (, bytes memory ret2) = address(this).call(payoutAddressCall);
        updatedPayoutAddress = abi.decode(ret2, (address));
        assertEq(updatedPayoutAddress, newPayoutAddress);
        assertFalse(updatedPayoutAddress == oldPayoutAddress);

        // remove `newPayoutAddress`
        vm.prank(owner_);
        bytes memory removePayoutCall =
            abi.encodeWithSelector(PayoutAddress.removePayoutAddress.selector, newPayoutAddress);
        (bool r2,) = address(this).call(removePayoutCall);
        require(r2);

        address removedPayoutAddress;
        (, bytes memory ret3) = address(this).call(payoutAddressCall);
        removedPayoutAddress = abi.decode(ret3, (address));
        assertEq(removedPayoutAddress, address(0x0));
        assertFalse(removedPayoutAddress == newPayoutAddress);
    }

    function test_removePayoutAddressRevertPermissionDoesNotExist() public {
        address oldPayoutAddress;
        (, bytes memory ret) = address(this).call(payoutAddressCall);
        oldPayoutAddress = abi.decode(ret, (address));
        address newPayoutAddress = createAccount();

        // set payoutAddress
        bytes memory updatePayoutCall =
            abi.encodeWithSelector(PayoutAddress.updatePayoutAddress.selector, newPayoutAddress);
        vm.prank(owner_);
        (bool r,) = address(this).call(updatePayoutCall);
        require(r);

        address updatedPayoutAddress;
        (, bytes memory ret2) = address(this).call(payoutAddressCall);
        updatedPayoutAddress = abi.decode(ret2, (address));
        assertEq(updatedPayoutAddress, newPayoutAddress);
        assertFalse(updatedPayoutAddress == oldPayoutAddress);

        // attempt to remove `newPayoutAddress` without ADMIN permission
        bytes memory removePayoutCall =
            abi.encodeWithSelector(PayoutAddress.removePayoutAddress.selector, newPayoutAddress);
        (bool r2,) = address(this).call(removePayoutCall);
        vm.expectRevert();
        require(r2);

        address unchangedPayoutAddress;
        (, bytes memory ret3) = address(this).call(payoutAddressCall);
        unchangedPayoutAddress = abi.decode(ret3, (address));
        assertEq(unchangedPayoutAddress, newPayoutAddress);
        assertFalse(unchangedPayoutAddress == address(0x0));
    }
}
