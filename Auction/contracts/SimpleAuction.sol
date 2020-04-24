pragma solidity >=0.4.25 <0.7.0;

contract SimpleAuction {

    uint public auctionEndTime;
    uint public highestBid;

    constructor( 
        //uint _biddingTime
    ) public {
        auctionEndTime = now + 10000000;
    }

    function getAuctionEndTime() public view returns(uint) {
		return auctionEndTime;
	}

    function bid() public payable {

        require(now <= auctionEndTime, "Auction already ended.");

        //require(msg.value > highestBid, "There already is a higher bid.");
        //highestBidder = msg.sender;

        highestBid = msg.value;

    }

}