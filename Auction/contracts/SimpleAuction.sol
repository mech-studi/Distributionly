pragma solidity >=0.4.25 <0.7.0;

contract SimpleAuction {

    uint public auctionEndTime;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    // Events that will be fired on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

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

        // If the bid is not higher, send the money back.
        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

}