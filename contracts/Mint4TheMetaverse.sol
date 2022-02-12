// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract ContextMixin {
    function msgSender()
        internal
        view
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}

contract Mint4TheMetaverse is ERC721, ERC721Enumerable, Ownable, ContextMixin {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeMath for uint32;
    using SafeMath for uint8;
    using Strings for uint;
    using Address for address;


    uint256 public maxSupply = 100000;
    bool public mintingEnabled;
    uint256 public buyLimit = 20;
    uint64 price1 = 0.00001 ether;
    uint64 price2 = 0.00002 ether;
    uint64 price3 = 0.00003 ether;


    struct Pixel {
        uint256 tokenId;
        address owner;
        string message;
        string color;
        bool isLocked;
        string title;
        bool isEditable;
    }

    struct canvasPixel{
        uint256 pixelNum;
        string color;
    }

    canvasPixel[] canvasPixels;

    mapping(uint => canvasPixel) public canvas;

    mapping(uint256 => Pixel) public pixels;


    constructor() 
    ERC721("4TheMetaverse", "4TM") {}


    function setMaxSupply(uint32 newMaxSupply) external onlyOwner {
        maxSupply = newMaxSupply;
    }

    function setBuyLimit(uint8 newBuyLimit) external onlyOwner {
        buyLimit = newBuyLimit;
    }

    function toggleMinting() external onlyOwner {
        mintingEnabled = !mintingEnabled;
    }

    function getChainID() external view returns (uint256) {
    uint256 id;
    assembly {
        id := chainid()
    }
    return id;
}


    function tokenMint( uint256 tokenNum) external payable {
        require(mintingEnabled, "Minting has not been enabled");
        require(balanceOf(msg.sender) < buyLimit, "Buy limit exceeded");
        require(totalSupply().add(1) <= maxSupply, "Purchase would exceed maximum supply of tokens");
        require(tokenNum > 0, "Token number must be greater than 0");
        require(tokenNum <= maxSupply, "Token number must be less than or equal to max supply");
        if(tokenNum <= 36250){
            require(0.00003 ether == msg.value, "Matic value sent is not correct");
        } else if( 36250 < tokenNum && tokenNum <= 78000){
            require(0.00002 ether == msg.value, "Matic value sent is not correct");
        } else {
            require(0.00001 ether == msg.value, "Matic value sent is not correct");
        }
            _safeMint(msg.sender, tokenNum);
            // Pixel storage pixel = pixels[tokenNum];
            // pixel.owner = msg.sender;
            // pixel.tokenId = tokenNum;
            // canvasPixel storage canvaspixel = canvas[tokenNum];
            // canvaspixel.pixelNum = tokenNum;        
    }

    function reserveToken(uint256 startPoint, uint256 endPoint) onlyOwner public {
        for (uint256 i = startPoint; i <= endPoint; i++) {
            _safeMint(msg.sender, i);
            // Pixel storage pixel = pixels[i];
            // pixel.owner = msg.sender;
            // pixel.tokenId = i;
            // canvasPixel storage canvaspixel = canvas[i];
            // canvaspixel.pixelNum = i;
        }
    }

    function fillUpPixel(uint32 tokenId, string memory message, string memory color, string memory title) external {
        require(ownerOf(tokenId) == msg.sender, "You do not own this token :{");
        Pixel storage pixel = pixels[tokenId];
        require(keccak256(abi.encodePacked(pixel.title)) == keccak256(abi.encodePacked("")), "Pixel is already filled, can only now be edited");
        canvasPixel storage canvaspixel  = canvas[tokenId];
        canvaspixel.pixelNum = tokenId;
        canvaspixel.color = color;
        pixel.message = message;
        pixel.color = color;
        pixel.title = title;
        pixel.isEditable = false;
        pixel.owner = msg.sender;
        pixel.isLocked = false;
        if(keccak256(abi.encodePacked(pixel.message)) == keccak256(abi.encodePacked(""))){
             canvasPixels.push(canvaspixel);
        }
    }

    function getCanvas() public view returns (canvasPixel[] memory) {
        return canvasPixels;
    }

    function lockPixel(uint256 tokenId) external onlyOwner {
        require(tokenId <= totalSupply(), "Bruv, this token does not even exist :[");
        Pixel storage pixel = pixels[tokenId];
        pixel.isLocked = true;
    }

    function editPixel(uint256 tokenId, string memory message, string memory title) external {
        require(ownerOf(tokenId) == msg.sender, "You do not own this token :{");
        Pixel storage pixel = pixels[tokenId];
        require(keccak256(abi.encodePacked(pixel.title)) != keccak256(abi.encodePacked("")), "Pixel is not even filled.");
        require(pixel.isEditable == true, "Pixel is not editable.");
        require(pixel.isLocked == false, "Pixel is locked.");
        pixel.message = message;
        pixel.title = title;
    }

    function _msgSender() internal override view returns (address sender){
        return ContextMixin.msgSender();
    }

    function getTokensByOwner(address _owner) external view returns(uint[] memory){
        uint[] memory result = new uint[](balanceOf(_owner));
        uint j = 0;
        for (uint i = 1; i <= totalSupply(); i++) {
            if (ownerOf(i) == _owner) {
                result[j] = i;
                j++;
            } else {
                continue;
            }
        }
        return result;
    }


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        pixels[tokenId].owner = to;
        pixels[tokenId].isEditable = true;
        super.safeTransferFrom(from, to, tokenId, "");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
  }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) public override view returns (bool isOperator) {
      // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }
        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721.isApprovedForAll(_owner, _operator);
    }

}