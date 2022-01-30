// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WatchNFTBuySell is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {

    // Mapping tokenId to the price. Used in allowBuy function
    mapping (uint256 => uint256) public tokenIdToPrice;
    
    // Count amount of minted NFTs Per wallet. 
    mapping(address => uint256) public mintedWallets;

    // Mapping tokenId to attributes
    mapping(uint256 => Attr) public attributes;

    struct Attr {
        string serialNumber;
        string creator;
        address creatorId;
        uint256 dateCreated;
    }

    // Creating an event for seller, buyer and price when "buy" function is called
    event purchaseInfo(address _seller, address _buyer, uint256 _price, uint256 _date);

    constructor() ERC721("WatchUpNFT", "WatchUP") {}

    function toUint256(bytes memory _bytes) // Used to convert msg.sender and serialNumber to uint256
        internal
        pure
        returns (uint256 value) {

        assembly {
        value := mload(add(_bytes, 0x20))
        }
    }

    function mint(
        address reciever,
        string memory uri,
        string memory serialNumber,
        string memory creator
                    ) external payable {
        
        //Requirement that serial number and creator is NOT empty
        require(bytes(serialNumber).length != 0,
                "Please enter Serial Number");

        require(bytes(creator).length != 0,
                "Please enter Serial Number");               

        // Creating tokenID by encoding msg.sender and serialNumber
        uint256 tokenId = toUint256(abi.encodePacked(msg.sender, serialNumber));
        
        // mint function with reciever and tokenId as input
        _safeMint(reciever, tokenId);

        // Creating the NFT's URI 
        _setTokenURI(tokenId, uri);

        // The added Attributes for the given token. Minter must manually enter Serial Number 
        // and creator (the watch maker or seller of watch)
        attributes[tokenId] = Attr(serialNumber, creator ,msg.sender,block.timestamp);

        // Counts minted NFTs per wallet
        mintedWallets[msg.sender]++;
        }
    

    // This function can only be called by the owner of the NFT. 
    // It allows the owner to select his NFT and set a price. When a price is set, other people can by the NFT.
    function allowBuy(uint256 _tokenId, uint256 _price) external {
        require(msg.sender == ownerOf(_tokenId), 'You do not own this NFT');
        require(_price > 0, 'Price zero');
        tokenIdToPrice[_tokenId] = _price;
    }
    // If the owner regrets he can call this funciton by entering tokenId and it will set the price to 0.
    function disallowBuy(uint256 _tokenId) external {
        require(msg.sender == ownerOf(_tokenId), 'You do not own this NFT');
        tokenIdToPrice[_tokenId] = 0;
    }
    // This function allows others to buy a NFT if the enter the tokenId.
    // A price needs to be above 0. If it is not then it means that it is not for sale
    function buy(uint256 _tokenId) external payable {
        uint256 price = tokenIdToPrice[_tokenId]; //get the token price
        require(price > 0, 'NFT currently not up for sale'); //if price != 0 then OK
        require(msg.value == price, 'You have entered the wrong value'); // The value needs to be equal to the seller price
        
        address seller = ownerOf(_tokenId);
        _transfer(seller, msg.sender, _tokenId); //using transfer function to transfer token 
        tokenIdToPrice[_tokenId] = 0; // Sets token price to zero after transfer, so it not for sale anymore
        payable(seller).transfer(msg.value); // the price in eth is sent to the seller

        emit purchaseInfo(seller, msg.sender, msg.value, block.timestamp); //emits the event created as state variable
    }
     // The following functions are overrides required by Solidity.
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
}
