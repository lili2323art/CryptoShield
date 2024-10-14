// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract PotsNFT is ERC721, Ownable {
    uint256 private _currentTokenId;

    string public baseTokenURI;
    uint256 public constant MAX_SUPPLY = 100;
    address owner;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        baseTokenURI = _baseTokenURI;
        owner = msg.sender;
    }

    function mintNFT(bytes memory signature) public returns (uint256) {
        require(_currentTokenId < MAX_SUPPLY, "Max supply reached");
        
        require(address(0x0647EcF0D64F65AdA7991A44cF5E7361fd131643) == ECDSA.recover(
            0x8144a6fa26be252b86456491fbcd43c1de7e022241845ffea1c3df066f7cfede,
            signature
        ), "unverified mint operation");
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
