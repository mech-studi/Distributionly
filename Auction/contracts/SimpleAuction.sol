pragma solidity >=0.4.25 <0.7.0;

contract SimpleAuction {

    uint public auctionEndTime;

    constructor( 
        uint _biddingTime
    ) public {
        auctionEndTime = now + _biddingTime;
    }

    function getAuctionEndTime() public view returns(uint) {
		return auctionEndTime;
	}

}