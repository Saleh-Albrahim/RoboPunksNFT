//SPX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import  '@openzeppelin/contracts/access/Ownable.sol';


contract RoboPunksNFT is ERC721, Ownable {

    uint256 public  mintPrice;
    uint256 public  totalSupply;
    uint256 public  maxSupply;
    uint256 public  maxPerWallet;
    bool public  isMintable;
    string internal  baseTokenURI;
    address payable public  withdrawWallet;
    mapping(address => uint256) public  walletMints;

    constructor() payable ERC721('RoboPunks','RP'){
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
    }

    function setIsMintable(bool _isMintable) external onlyOwner {
        isMintable = _isMintable;
    }

    function setBaseTokenURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId),'Token does not exist !');
        return string(abi.encodePacked(baseTokenURI,Strings.toString(_tokenId),'.json'));
    }

    function withdraw() external onlyOwner {
       (bool success,) = withdrawWallet.call{value : address(this).balance}('');
       require(success,'Withdraw failed !');
    }

    function mint(uint256 _quantity) public payable {
        require(isMintable,'Token is not mintable !');
        require(msg.value == _quantity * mintPrice,'Not enough funds !');
        require(totalSupply + _quantity <= maxSupply,'Max supply reached !');
        require(walletMints[msg.sender] + _quantity <= maxPerWallet,'Max per wallet reached !');

        for (uint i = 0; i < _quantity; i++) {
            uint256 tokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, tokenId);
        }
    }
}