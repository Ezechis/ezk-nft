// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title EzkNFT — "Lagos Circuit" collection by Ezechi Kingsley
/// @notice ERC-721 with per-token metadata URIs (IPFS or data URI), owner-only minting and a fixed supply cap.
contract EzkNFT is ERC721URIStorage, Ownable {
    uint256 public constant MAX_SUPPLY = 100;

    uint256 private _nextTokenId;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);

    error MaxSupplyReached();
    error EmptyTokenURI();

    constructor(address initialOwner) ERC721("Lagos Circuit", "EZK") Ownable(initialOwner) {}

    /// @notice Mint a new token to `to` pointing at `uri`. Token ids start at 0.
    function mintNFT(address to, string calldata uri) external onlyOwner returns (uint256 tokenId) {
        if (_nextTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (bytes(uri).length == 0) revert EmptyTokenURI();

        tokenId = _nextTokenId++;
        _setTokenURI(tokenId, uri);
        emit NFTMinted(to, tokenId, uri);

        // External call (onERC721Received) last: checks-effects-interactions.
        _safeMint(to, tokenId);
    }

    function totalMinted() external view returns (uint256) {
        return _nextTokenId;
    }
}
