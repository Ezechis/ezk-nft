// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EzkNFT} from "../src/EzkNFT.sol";

contract EzkNFTTest is Test {
    EzkNFT internal nft;

    address internal owner = makeAddr("owner");
    address internal alice = makeAddr("alice");
    string internal constant URI = "ipfs://bafkreiexamplemetadata/0.json";

    function setUp() public {
        nft = new EzkNFT(owner);
    }

    function test_NameAndSymbol() public view {
        assertEq(nft.name(), "Lagos Circuit");
        assertEq(nft.symbol(), "EZK");
        assertEq(nft.owner(), owner);
    }

    function test_OwnerCanMint() public {
        vm.prank(owner);
        uint256 id = nft.mintNFT(alice, URI);

        assertEq(id, 0);
        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.balanceOf(alice), 1);
        assertEq(nft.tokenURI(0), URI);
        assertEq(nft.totalMinted(), 1);
    }

    function test_TokenIdsIncrement() public {
        vm.startPrank(owner);
        nft.mintNFT(alice, URI);
        uint256 second = nft.mintNFT(alice, URI);
        vm.stopPrank();

        assertEq(second, 1);
        assertEq(nft.balanceOf(alice), 2);
    }

    function test_EmitsNFTMinted() public {
        vm.expectEmit(true, true, false, true);
        emit EzkNFT.NFTMinted(alice, 0, URI);

        vm.prank(owner);
        nft.mintNFT(alice, URI);
    }

    function test_RevertWhen_NonOwnerMints() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        nft.mintNFT(alice, URI);
    }

    function test_RevertWhen_EmptyURI() public {
        vm.prank(owner);
        vm.expectRevert(EzkNFT.EmptyTokenURI.selector);
        nft.mintNFT(alice, "");
    }

    function test_RevertWhen_MaxSupplyReached() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < nft.MAX_SUPPLY(); i++) {
            nft.mintNFT(alice, URI);
        }
        vm.expectRevert(EzkNFT.MaxSupplyReached.selector);
        nft.mintNFT(alice, URI);
        vm.stopPrank();
    }

    function test_RevertWhen_TokenDoesNotExist() public {
        vm.expectRevert();
        nft.tokenURI(42);
    }

    function testFuzz_MintToAnyEOA(address to) public {
        vm.assume(to != address(0) && to.code.length == 0);
        vm.prank(owner);
        uint256 id = nft.mintNFT(to, URI);
        assertEq(nft.ownerOf(id), to);
    }
}
