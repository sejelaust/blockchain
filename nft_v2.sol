// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WatchNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
   // mapping(uint256 => string) SerialNumber;
    mapping(uint256 => address) OriginalMinter;
    mapping(uint256 => Attr) public attributes;

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

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        attributes[tokenId] = Attr(serialNumber, creator ,msg.sender);
        
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
