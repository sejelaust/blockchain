// SPDX-License-Identifier: Unlicense

// msg.sender gives information about the person running the function
// // msg.value

pragma solidity ^0.8.11;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract SimpleMintContract is ERC721, Ownable {
    // Price for minting NFT
    uint256 public mintPrice = 0.005 ether; 
    // Counts the total amount of NFT's minted
    uint256 public totalSupply;
    // If we want a max amount of supply
    uint256 public maxSupply;
    //Set to TRUE when people can mint
    bool public isMintEnabled;
    //Event 
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event MintMessage(string message);
    event Log(address indexed sender, string message);
    event AnotherLog();
    mapping(address => uint256) public mintedWallets;
   // mapping(uint256 => string) name;
    // Add so only specific users can mint
    function fireEvents() external {
        emit Log(msg.sender, "Test");
        emit AnotherLog();
    }
    constructor() payable ERC721('Simple Mint', 'SIMPLEMINT') {
        maxSupply = 2;
    }



    // This function can only be run by the owner from 'Ownable'
    function toggleIsMintEnabled() external onlyOwner {
        //When this function is being runned it will set 'isMintEnabled' to true ('!isMintEnabled' will convert the default, false, to true)
        isMintEnabled = !isMintEnabled;
    }

    function setMaxSupply(uint256 maxSupply_) external onlyOwner {
        maxSupply = maxSupply_;
    }


    function mint() external payable {
        //This function says if "isMintEnabled" = false then give error
        require(isMintEnabled, 'mintin not enabled');
        // The amount each wallet can mint. We need no such requrements
        require(mintedWallets[msg.sender] < 5, 'exceeds mac per wallet');
        // Makes sure that the correct price for the mint is entered
        require(msg.value == mintPrice, 'wrong value');
        // if we want to limit the amount of nfts
        require(maxSupply > totalSupply, 'sold out');

        // Every time a wallet mints a nft the "mintedWallets" will increase by 1
        mintedWallets[msg.sender]++;
        // the total supply will increase by 1
        totalSupply++;
        // Creates a id for the total supply. so the first NFT id is 1. Saving this in a temporary local variable will save us some gas
        uint256 tokenId = totalSupply;
        //set serial number
       // emit MintMessage(message);
        // _safeMint comes from the ERC721, it makes sure that the token is distributed correctly
        _safeMint(msg.sender, tokenId);
      //  emit MintMessage(message);
    }

    function safeTransfer external payable {
        require();
        safeTransferFrom(msg.sender, msg.)
    }
 }
