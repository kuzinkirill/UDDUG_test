// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MyUddugERC is ERC721 {

    using ECDSA for bytes32;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant SET_LENGTH = 6;
    uint256 public constant MAX_SINGLE_MINT_PER_ADDRESS = 3;

    uint256 public immutable tokenPrice;
    uint256 public immutable setPrice;
    uint public tokenIdCounter = 1;

    mapping(address => uint) mintAmount;
    mapping(bytes32 => bool) public usedSignatures;
    mapping(address => bool) public setMinted;

    event newSetMinted(address indexed to, uint256[] tokenIds, uint256 amountPaid);

    constructor(string memory _name, string memory _symbol, uint256 _tokenPrice, uint256 _setPrice)
        ERC721(_name, _symbol)
    {
        tokenPrice = _tokenPrice;
        setPrice = _setPrice;
    }

    function singleMint() external payable {
        require(tokenIdCounter < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= tokenPrice, "Insufficient funds");
        require(mintAmount[msg.sender] < MAX_SINGLE_MINT_PER_ADDRESS, "Maximum mints reached");

        uint256 tokenId = tokenIdCounter;
        tokenIdCounter++;
        mintAmount[msg.sender]++;
        _mint(msg.sender, tokenId);
    }

    function signedSingleMint(uint256 _tokenId, bytes calldata _signature) external {
        
        require(mintAmount[msg.sender] < MAX_SINGLE_MINT_PER_ADDRESS, "Maximum mints reached");
        require(_tokenId > 0 && _tokenId <= MAX_SUPPLY, "Invalid tokenId");
        require(tokenIdCounter == _tokenId, "Invalid todenId #2");

        bytes32 messageHash = keccak256(abi.encodePacked(_tokenId, msg.sender, address(this))); //keccak256(abi.encodePacked(_tokenId, msg.sender));
        address recoveredAddress = ECDSA.recover(messageHash, _signature); //address recoveredAddress = messageHash.toEthSignedMessageHash().recover(_signature);
        require(recoveredAddress == msg.sender, "Invalid signature");

        require(!usedSignatures[messageHash], "The signuture has already been used");

        tokenIdCounter++;

        mintAmount[msg.sender]++;
        usedSignatures[messageHash] = true;
        _mint(msg.sender, _tokenId);
    }

    function mintSet() external payable {
        require(tokenIdCounter <= (MAX_SUPPLY - SET_LENGTH), "Max supply reached");
        require(msg.value >= setPrice, "Insufficient funds");
        require(!setMinted[msg.sender], "You have already minted a set");

        setMinted[msg.sender] = true;

        uint256[] memory mintedTokenIds = new uint256[](SET_LENGTH);

        for (uint256 i = 0; i < SET_LENGTH; i++) {
            uint256 tokenId = tokenIdCounter;
            mintedTokenIds[i] = tokenId;
            tokenIdCounter++;
            _mint(msg.sender, tokenId);
        }

        emit newSetMinted(msg.sender, mintedTokenIds, msg.value);
    }
}
