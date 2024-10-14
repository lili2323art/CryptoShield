// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/NFT.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DeployPotsNFT is Script {
    using Strings for uint256;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 生成新的密钥对用于签名验证
        uint256 newPrivateKey = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, address(this))));
        address newPublicKey = vm.addr(newPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        PotsNFT potsNFT = new PotsNFT(
            "Pots NFT",
            "POTS",
            "ipfs://QmY56knz2skf7nwfhj7zte2mxjs3pdepifew36y3lne52yjkewgam/metadata/",
            newPublicKey  // 使用新生成的公钥作为签名验证地址
        );

        vm.stopBroadcast();

        console.log("PotsNFT deployed to:", address(potsNFT));
        console.log("New signer public key:", newPublicKey);
        console.log("New signer private key (keep this secret!):", newPrivateKey);
        console.log("New signer private key Hash (keep this secret!):", newPrivateKey.toHexString());
    }
}
