// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WatchNFTBuySell is ERC721, ERC721Enumerable,ERC721URIStorage, ERC721Burnable, Ownable {
    //
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
   // mapping(uint256 => string) SerialNumber;
    mapping(uint256 => Attr) public attributes;

    struct Attr {
        string serialNumber;
        string creator;
        address creatorId;
        
    }

    mapping (uint256 => uint256) public tokenIdToPrice;

    event NftBought(address _seller, address _buyer, uint256 _price);

    // Count amount of minted NFT Per wallet
    mapping(address => uint256) public mintedWallets;

    constructor() ERC721("WatchNFT", "MTK") {}

    function safeMint(string memory uri) external payable onlyOwner {
       // require(SerialNumber < 1, 'You are missing Serial Number');
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
       // mapping(uint256 => string) SerialNumber;
    }


    function mint(
        address reciever,
        string memory uri,
        string memory serialNumber,
        string memory creator
                    ) external payable {
        
        //Requirement that serial number and creater is NOT empty
        require(bytes(serialNumber).length != 0,
                "Please enter Serial Number");

            require(bytes(creator).length != 0,
                "Please enter Serial Number");               

        //Setting the tokenId to the current tokenId counter (ie. first one is 0)
        uint256 tokenId = _tokenIdCounter.current();


        // Increasing the token ID with 1 each time a token is minted
        _tokenIdCounter.increment();
        
        //tokenId = msg.sender + memory serialNumber
        
        // mint function with reciever and tokenId as input
        _safeMint(reciever, tokenId);

        //Creating the NFT's URI 
        _setTokenURI(tokenId, uri);

        // The added Attributes for the given token. Minter must manually enter Serial Number and creator (the watch maker or seller of watch)
        attributes[tokenId] = Attr(serialNumber, creator ,msg.sender);

        // Counts minted NFTs per wallet
        mintedWallets[msg.sender]++;
        }
    


    function allowBuy(uint256 _tokenId, uint256 _price) external {
        require(msg.sender == ownerOf(_tokenId), 'Not owner of this token');
        require(_price > 0, 'Price zero');
        tokenIdToPrice[_tokenId] = _price;
    }

    function disallowBuy(uint256 _tokenId) external {
        require(msg.sender == ownerOf(_tokenId), 'Not owner of this token');
        tokenIdToPrice[_tokenId] = 0;
    }
    
    function buy(uint256 _tokenId) external payable {
        uint256 price = tokenIdToPrice[_tokenId];
        require(price > 0, 'This token is not for sale');
        require(msg.value == price, 'Incorrect value');
        
        address seller = ownerOf(_tokenId);
        _transfer(seller, msg.sender, _tokenId);
        tokenIdToPrice[_tokenId] = 0; // not for sale anymore
        payable(seller).transfer(msg.value); // send the ETH to the seller

        emit NftBought(seller, msg.sender, msg.value);
    }
     // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
