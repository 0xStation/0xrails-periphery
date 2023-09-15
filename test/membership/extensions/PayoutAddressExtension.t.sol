// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PayoutAddressExtension} from "src/membership/extensions/PayoutAddress/PayoutAddressExtension.sol";
import {MetadataRouter} from "src/metadataRouter/MetadataRouter.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PayoutAddressExtensionTest is Test {

    PayoutAddressExtension public payoutAddressExtension;
    MetadataRouter public exampleRouterImpl;
    MetadataRouter public exampleRouterProxy;

    address public owner;
    string public someURI;
    string public someRoute;
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
        someURI = "someURI";
        uris = new string[](1);
        uris[0] = someURI;
        initData = abi.encodeWithSelector(
            MetadataRouter.initialize.selector, owner, someURI, routes, uris
        );

        exampleRouterImpl = new MetadataRouter();
        exampleRouterProxy = MetadataRouter(address(new ERC1967Proxy(address(exampleRouterImpl), initData)));

        payoutAddressExtension = new PayoutAddressExtension(address(exampleRouterProxy));
    }

    function test_setUp() public {
        string memory returnedURI = exampleRouterProxy.routeURI(someRoute);
        string memory expectedURI = someURI;
        assertEq(returnedURI, expectedURI);
    }

    function test_getAllSelectors() public {}
    function test_signatureOf() public {}
    function test_updatePayoutAddress() public {}
    function test_removePayoutAddress() public {}
}