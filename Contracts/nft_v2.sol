// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WatchNFT is ERC721, ERC721Enumerable,ERC721URIStorage, ERC721Burnable, Ownable {
    //
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
   // mapping(uint256 => string) SerialNumber;
    mapping(uint256 => address) OriginalMinter;
    mapping(uint256 => Attr) public attributes;

    // Count amount of minted NFT Per wallet
    mapping(address => uint256) public mintedWallets;
    struct Attr {
        string serialNumber;
        string creator;
        address creatorId;
        
    }


    constructor() ERC721("WatchNFT", "MTK") {}


    function safeMint(string memory uri) external payable onlyOwner {
       // require(SerialNumber < 1, 'You are missing Serial Number');
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
       // mapping(uint256 => string) SerialNumber;
    }

    function mint(string memory uri,string memory serialNumber, string memory creator) external payable onlyOwner {
        
        //CREATE requirement that Each serial number must be unique
        // requirement that attributes must not be emty when minting? 

        //Setting the tokenId to the current tokenId counter (ie. first one is 0)
        uint256 tokenId = _tokenIdCounter.current();

        // Increasing the token ID with 1 each time a token is minted
        _tokenIdCounter.increment();

        // Safemint function using "msg.sender", the wallet id minting the NFT and the token ID. 
        _safeMint(msg.sender, tokenId);

        //Creating the NFT's URI 
        _setTokenURI(tokenId, uri);

        // The added Attributes for the given token. Minter must manually enter Serial Number and creator (the watch maker or seller of watch)
        attributes[tokenId] = Attr(serialNumber, creator ,msg.sender);

        // Counts minted NFTs per wallet
        mintedWallets[msg.sender]++;
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
