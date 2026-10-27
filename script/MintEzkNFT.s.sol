// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {EzkNFT} from "../src/EzkNFT.sol";

/// NFT_ADDRESS=0x... forge script script/MintEzkNFT.s.sol --rpc-url sepolia --account <keystore> --broadcast
/// Set TOKEN_URI=ipfs://<cid> to use Pinata-hosted metadata; otherwise the art in nft/ is embedded on-chain.
contract MintEzkNFT is Script {
    function run() external returns (uint256 tokenId) {
        EzkNFT nft = EzkNFT(vm.envAddress("NFT_ADDRESS"));
        address to = vm.envOr("MINT_TO", msg.sender);
        string memory uri = vm.envOr("TOKEN_URI", onChainTokenURI());

        vm.startBroadcast();
        tokenId = nft.mintNFT(to, uri);
        vm.stopBroadcast();

        console.log("Minted token id:", tokenId);
        console.log("Owner of token:", nft.ownerOf(tokenId));
        console.log("Total minted:", nft.totalMinted());
    }

    function onChainTokenURI() public view returns (string memory) {
        string memory svg = vm.readFile("nft/lagos-circuit-0.svg");
        string memory json = string.concat(
            '{"name":"Lagos Circuit #0","description":"A Lagos skyline at dusk wired into a circuit board. Minted by Ezechi Kingsley with Foundry.",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '","attributes":[{"trait_type":"City","value":"Lagos"},{"trait_type":"Palette","value":"Dusk"},{"trait_type":"Edition","value":"Genesis"}]}'
        );
        return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
    }
}
