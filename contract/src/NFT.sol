// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PotsNFT is ERC721, Ownable {
    uint256 private _currentTokenId;

    string public baseTokenURI;
    uint256 public constant MAX_SUPPLY = 100;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFT() public returns (uint256) {
        require(_currentTokenId < MAX_SUPPLY, "Max supply reached");
        // 获取当前交易hash
        bytes32 hash = keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender));
        _currentTokenId++;
        uint256 newItemId = _currentTokenId;
        _safeMint(msg.sender, newItemId);
        return newItemId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Strings.toString(tokenId),
                        ".json"
                    )
                )
                : "";
    }
}
