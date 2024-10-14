// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/NFT.sol";

contract DeployPotsNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        PotsNFT potsNFT = new PotsNFT(
            "Pots NFT",
            "POTS",
            "ipfs://QmY56knz2skf7nwfhj7zte2mxjs3pdepifew36y3lne52yjkewgam/metadata/"
        );

        vm.stopBroadcast();

        console.log("PotsNFT deployed to:", address(potsNFT));
    }
}
