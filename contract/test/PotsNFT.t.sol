// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NFT.sol";

contract PotsNFTTest is Test {
    PotsNFT public nft;
    address public owner;
    address public signer;
    address public user;

    function setUp() public {
        owner = address(this);
        signer = vm.addr(1024);
        user = vm.addr(2);

        nft = new PotsNFT(
            "Pots NFT",
            "POTS",
            "https://example.com/metadata/",
            signer
        );
    }

    function testMintNFT() public {
        uint256 tokenId = 1;
        bytes32 messageHash = keccak256(abi.encodePacked(user, tokenId));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1024, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        // log signature
        console.logBytes(signature);
        vm.prank(user);
        uint256 mintedTokenId = nft.mintNFT(signature);

        assertEq(mintedTokenId, tokenId, "Minted token ID should be 1");
        assertEq(nft.ownerOf(tokenId), user, "User should own the minted NFT");
        assertEq(nft.totalSupply(), 1, "Total supply should be 1 after minting");
    }

    function testFailMintWithInvalidSignature() public {
        uint256 tokenId = 1;
        bytes32 messageHash = keccak256(abi.encodePacked(user, tokenId));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, messageHash); // Using wrong private key
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(user);
        nft.mintNFT(signature); // This should fail
    }

    function testFailMintBeyondMaxSupply() public {
        for (uint256 i = 1; i <= 100; i++) {
            uint256 tokenId = i;
            bytes32 messageHash = keccak256(abi.encodePacked(user, tokenId));
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, messageHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            vm.prank(user);
            nft.mintNFT(signature);
        }

        // Attempt to mint 101st NFT
        bytes32 messageHash = keccak256(abi.encodePacked(user, uint256(101)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(user);
        nft.mintNFT(signature); // This should fail
    }

    function testSetBaseURI() public {
        string memory newBaseURI = "https://newexample.com/metadata/";
        nft.setBaseURI(newBaseURI);

        uint256 tokenId = 1;
        bytes32 messageHash = keccak256(abi.encodePacked(user, tokenId));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(user);
        nft.mintNFT(signature);

        assertEq(nft.tokenURI(tokenId), string(abi.encodePacked(newBaseURI, "1.json")), "Token URI should be updated");
    }

    function testSetSignerAddress() public {
        address newSigner = vm.addr(3);
        nft.setSignerAddress(newSigner);

        assertEq(nft.signerAddress(), newSigner, "Signer address should be updated");

        // Test minting with new signer
        uint256 tokenId = 1;
        bytes32 messageHash = keccak256(abi.encodePacked(user, tokenId));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(3, messageHash); // Using new signer's private key
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(user);
        uint256 mintedTokenId = nft.mintNFT(signature);

        assertEq(mintedTokenId, tokenId, "Minted token ID should be 1");
    }
}
