// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MockAccountDeployer} from "lib/0xrails/test/lib/MockAccount.sol";
import {Operations} from "0xrails/lib/Operations.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {PayoutAddress} from "src/membership/extensions/PayoutAddress/PayoutAddress.sol";
import {MetadataRouter} from "src/metadataRouter/MetadataRouter.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PayoutAddressExtensionTest is Test, MockAccountDeployer {

    PayoutAddressExtension public payoutAddressExtension;
    MetadataRouter public exampleRouterImpl;
    MetadataRouter public exampleRouterProxy;

    address public owner;
    string public someRoute;
    string public defaultURI;
    string public someURI;
    string[] public routes;
    string[] public uris;
    bytes public initData;

    // to store expected revert errors
    bytes err;

    function setUp() public {
        owner = vm.addr(0xbeefEEbabe);
        someRoute = "token";
        routes = new string[](1);
        routes[0] = someRoute;
        defaultURI = "default";
        someURI = "someURI";
        uris = new string[](1);
        uris[0] = someURI;
        initData = abi.encodeWithSelector(
            MetadataRouter.initialize.selector, owner, defaultURI, routes, uris
        );

        exampleRouterImpl = new MetadataRouter();
        exampleRouterProxy = MetadataRouter(address(new ERC1967Proxy(address(exampleRouterImpl), initData)));

        // deploy payoutAddressExtension as `owner` so it grants `owner` ADMIN permission
        vm.prank(owner);
        payoutAddressExtension = new PayoutAddressExtension(address(exampleRouterProxy));
    }

    function test_setUp() public {
        string memory returnedURI = exampleRouterProxy.routeURI(someRoute);
        string memory expectedURI = someURI;
        assertEq(returnedURI, expectedURI);
        
        string memory returnedDefault = exampleRouterProxy.defaultURI();
        string memory expectedDefault = defaultURI;
        assertEq(returnedDefault, expectedDefault);
    }

    function test_getAllSelectors() public {
        bytes4[] memory selectors = payoutAddressExtension.getAllSelectors();
        assertEq(selectors.length, 3);
        assertEq(selectors[0], PayoutAddress.payoutAddress.selector);
        assertEq(selectors[1], PayoutAddress.updatePayoutAddress.selector);
        assertEq(selectors[2], PayoutAddress.removePayoutAddress.selector);
    }

    function test_signatureOf() public {
        bytes4[] memory selectors = payoutAddressExtension.getAllSelectors();
        string memory returnedPayoutAddressSignature = payoutAddressExtension.signatureOf(selectors[0]);
        string memory expectedPayoutAddressSignature = "payoutAddress()";
        assertEq(returnedPayoutAddressSignature, expectedPayoutAddressSignature);

        string memory updatePayoutSignature = payoutAddressExtension.signatureOf(selectors[1]);
        string memory expectedUpdatePayoutSignature = "updatePayoutAddress(address)";
        assertEq(updatePayoutSignature, expectedUpdatePayoutSignature);

        string memory removePayoutSignature = payoutAddressExtension.signatureOf(selectors[2]);
        string memory expectedRemovePayoutSignature = "removePayoutAddress()";
        assertEq(removePayoutSignature, expectedRemovePayoutSignature);
    }

    function test_updatePayoutAddress() public {
        address newPayoutAddress = createAccount();

        vm.prank(owner);
        payoutAddressExtension.updatePayoutAddress(newPayoutAddress);

        assertEq(payoutAddressExtension.payoutAddress(), newPayoutAddress);
    }


}