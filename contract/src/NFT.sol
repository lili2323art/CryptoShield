// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract PotsNFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 private _currentTokenId;
    string public baseTokenURI;
    uint256 public constant MAX_SUPPLY = 100;
    address public signerAddress;  // 新增：用于验证签名的地址

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address _signerAddress
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        baseTokenURI = _baseTokenURI;
        signerAddress = _signerAddress;  // 设置签名验证地址
    }

    function mintNFT(bytes memory signature) public returns (uint256) {
        require(_currentTokenId < MAX_SUPPLY, "Max supply reached");

        bytes32 msgHash = keccak256(abi.encode(msg.sender, _currentTokenId + 1));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(msgHash);

        address recoveredSigner = ECDSA.recover(ethSignedMessageHash, signature);

        require(signerAddress == recoveredSigner,
            string(abi.encodePacked(
                "Invalid signature. Recovered: ",
                Strings.toHexString(uint160(recoveredSigner), 20),
                ", Expected: ",
                Strings.toHexString(uint160(signerAddress), 20),
                ", Message Hash: ",
                Strings.toHexString(uint256(msgHash), 32),
                ", Eth Signed Message Hash: ",
                Strings.toHexString(uint256(ethSignedMessageHash), 32),
                ", Signature: ",
                Strings.toHexString(uint(uint160(bytes20(signature))), 20),
                ", msg.sender: ",
                Strings.toHexString(uint160(msg.sender), 20),
                ", tokenId: ",
                Strings.toString(_currentTokenId + 1)
            ))
        );

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

    // 添加一个函数来更新签名验证地址
    function setSignerAddress(address _newSignerAddress) public onlyOwner {
        signerAddress = _newSignerAddress;
    }
}
