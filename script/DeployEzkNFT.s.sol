// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {EzkNFT} from "../src/EzkNFT.sol";

/// forge script script/DeployEzkNFT.s.sol --rpc-url sepolia --account <keystore> --broadcast
contract DeployEzkNFT is Script {
    function run() external returns (EzkNFT nft) {
        (, address deployer,) = vm.readCallers();

        vm.startBroadcast(deployer);
        nft = new EzkNFT(deployer);
        vm.stopBroadcast();

        console.log("EzkNFT deployed at:", address(nft));
        console.log("Owner:", nft.owner());
    }
}
