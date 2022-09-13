// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;



interface IERC721 {
  
function ownerOf(uint256 tokenId) external view returns (address owner);
function safeTransferFrom( address from, address to, uint256 tokenId ) external;

}


contract Auction{
    
    uint public nftId;
    uint public duration;
    uint public startTime;
    uint public timeElapsed;
    uint public startPrice;
    uint public discountRate;
    address public seller;
    mapping (uint => bool) isAuctioned;

    IERC721 public nft;

    event AuctionStarted(uint startPrice, uint duration, address seller, uint nftId );
    
   
   constructor(IERC721 _nftContract) {
    nft = IERC721(_nftContract);
   }
  
  

  function startAuction(uint _duration, uint _startprice, uint _discountRate, uint _nftId) public {
      require(nft.ownerOf(_nftId) == msg.sender && isAuctioned[_nftId] == false, "You're not the owner or it's currently auctioned");
      require(_startprice >= _duration * _discountRate, "Start price should be higher");
      duration = _duration;
      startTime = block.timestamp;
      startPrice = _startprice;
      discountRate = _discountRate;
      seller  = payable(msg.sender);
      nftId = _nftId;
      isAuctioned[nftId] = true;

      emit AuctionStarted( startPrice, duration, seller, nftId);
  }

  
  function getPrice() public returns(uint) {
        timeElapsed = block.timestamp - startTime;
        uint discount = discountRate * timeElapsed;
        return startPrice - discount;
  }

  
  function bid() external payable {
      require(startTime + duration > block.timestamp, "Auction expired");
      require(isAuctioned[nftId]);

      uint currentPrice = getPrice();

      require(msg.value >= currentPrice, "ETH < price");
      nft.safeTransferFrom(seller, msg.sender, nftId );
      
      uint refund  = msg.value - currentPrice;
      if(refund > 0) {
        payable(msg.sender).transfer(refund);
      }

      selfdestruct(payable(seller));
  } 

 


}
