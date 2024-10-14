// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "../src/NFT.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFTTest is Test {
    PotsNFT public nft;
    uint256 private signerPrivateKey;
    address public signerAddress;

    function setUp() public {
        // 生成一个随机的私钥和对应的地址
        signerPrivateKey = 0xA11CE;
        signerAddress = vm.addr(signerPrivateKey);

        // 部署 NFT 合约
        nft = new PotsNFT("TestNFT", "TNFT", "https://example.com/", signerAddress);
    }

    function testMintNFT() public {
        address minter = address(0xB0B);
        uint256 tokenId = 1; // 第一个 NFT 的 ID

        // 构造消息
        bytes32 message = keccak256(abi.encodePacked(minter, tokenId));

        // 使用 ECDSA 签名消息
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, message);
        bytes memory signature = abi.encodePacked(r, s, v);

        // 打印相关信息
        console.log("Minter address:", minter);
        console.log("Token ID:", tokenId);
        console.log("Message hash:", vm.toString(message));
        console.log("Signature:", vm.toString(signature));

        // 验证签名
        address recoveredSigner = ECDSA.recover(message, signature);
        console.log("Recovered signer:", recoveredSigner);
        console.log("Expected signer:", signerAddress);

        // 切换到 minter 地址
        vm.prank(minter);

        // 尝试铸造 NFT
        uint256 mintedTokenId = nft.mintNFT(signature);

        // 验证铸造结果
        assertEq(mintedTokenId, tokenId, "Minted token ID should match expected ID");
        assertEq(nft.ownerOf(tokenId), minter, "Minter should own the newly minted NFT");
    }
}
