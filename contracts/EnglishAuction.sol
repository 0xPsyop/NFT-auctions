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
    uint public highestBid;
    address public highestBidder;
    address payable public seller;
    mapping (uint => bool) public isAuctioned;
    mapping(address => uint) public bids;


    IERC721 public nft;
    
    event AuctionStarted(uint startPrice, uint duration, address seller, uint nftId );
    event Bid(address indexed sender, uint amount);
    event AuctionEnded (uint endPrice, address newOwner);
    
    constructor(IERC721 _nftContract) {
    nft = IERC721(_nftContract);
   }

   function startAuction(uint _duration, uint _startprice, uint _nftId) public {
   
     require(nft.ownerOf(_nftId) == msg.sender, "You must be the owner");
     nft.safeTransferFrom(msg.sender, address(this), _nftId);
     duration = _duration;
     startTime = block.timestamp;
     highestBid = _startprice;
     seller  = payable(msg.sender);
     nftId = _nftId;
     isAuctioned[nftId] = true;
    
     
     emit AuctionStarted( startPrice, duration, seller, nftId);
   }


  function bid() external payable{
      require(startTime + duration > block.timestamp, "Auction expired");
      require(isAuctioned[nftId] && msg.value > highestBid);

      if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
  }
  
  function withdraw() external {
      uint balance = bids[msg.sender];
      bids[msg.sender] = 0;
      payable(msg.sender).transfer(balance);
  }

  function endAuction() external{
     require(startTime + duration < block.timestamp, "Auction ongoing");
     
      if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }
     isAuctioned[nftId]=  false;
     emit AuctionEnded(highestBid, highestBidder);

  }
}