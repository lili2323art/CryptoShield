// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/NFT.sol";

contract UpdateSignerAddressScript is Script {
    // 请替换为您的 NFT 合约地址
    address constant NFT_CONTRACT_ADDRESS = 0xe54Bc60304c760821ffE96269F2435a422ba8cB2;
    // 请替换为新的 signer 地址
    address constant NEW_SIGNER_ADDRESS = 0x356040dff9cf9a9e018484a8c1eefa68e0c08f96;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        PotsNFT nft = PotsNFT(NFT_CONTRACT_ADDRESS);
        nft.setSignerAddress(NEW_SIGNER_ADDRESS);

        vm.stopBroadcast();

        console.log("Signer address updated to:", NEW_SIGNER_ADDRESS);
    }
}
