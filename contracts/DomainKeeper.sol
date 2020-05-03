pragma solidity >=0.5.1 <0.7.0;

contract DomainKeeper{
    uint256 counter = 0 ; 
    mapping(uint256 => iDomain) domains; 
    
    
    struct iDomain{
        uint _id;
        address owner;
        uint256 endcontract;
        string  domainname;
        
    }

    // the event is going to show which damain is close to be free and preparing for a new auction
    event DomainFree(
        uint256 endcontract,// date in wich the contract is close to end
        string domainname //the name of the domain
        );
    
        
    // function to add new domainname:    
    function configurateDomain(address  _owner, string memory  _domainame ) public payable returns(string memory){
        
        if ( !alreadyregister(_domainame)){
            counter += 1;
            domains[counter] = iDomain(counter,_owner,now, _domainame);
            return("The domain was register");
        }else{
            return("Error:! The domain was alreadyregister");
        }
    } 
    
    function getOwner(uint256 id) public view returns(address){
        return domains[id].owner;
       
    }
    
    function getDomainName(uint256 id) public view returns(string memory){
        return domains[id].domainname;
       
    }

    // function to checked if the ip is already in our register
    function alreadyregister(string memory newDomain)public view returns(bool){
         
        for (uint i = 0; i <= counter; i++){
            string memory s1 = domains[i].domainname; 
            if(keccak256(abi.encodePacked(newDomain))==keccak256(abi.encodePacked(s1))){
                return true;
            } 
        }
        return false;
    }
    
    function compareStringsbyBytes(string memory s,uint256 index) public view returns(bool){
        string memory s1 = domains[index].domainname; 
        if(keccak256(abi.encodePacked(s))==keccak256(abi.encodePacked(s1))){ 
           return true; 
        }
        return false; 
    }
    
    function dateclosetofinish(uint256 index) external {
        if(domains[index].endcontract == now -604800){ // has to be the time.stamp 
            emit DomainFree(domains[index].endcontract,domains[index].domainname);
        }
    }
   
    
    // ========================================================
    // AUCTION STUFF
    // Based on: https://solidity.readthedocs.io/en/v0.6.6/solidity-by-example.html#simple-open-auction
    // ========================================================

    struct iAuction {
        uint256 auctionEndTime;
        address highestBidder;
        uint256 highestBid;
        mapping(address => uint256) pendingReturns;   // Allowed withdrawals of previous bids
        bool ended; // Set to true at the end, disallows any change.
        bool exists;
    }

    mapping(bytes32 => iAuction) auctions;

    // Auction Events
    event AuctionStarted(bytes32 dHash, string domain, address account, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event HighestBidIncreased(address bidder, uint256 amount);

    /// Single place to do the domain name hashing.
    function hashDomain(string memory domain) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(domain));
    }

    /// Bid on the auction with the value sent together with this transaction.
    /// The value will only be refunded if the auction is not won.
    function bid(string memory _domain) public payable {
        bytes32 dh = hashDomain(_domain);

        // create new auction if no entry is available.
        if (!auctions[dh].exists) {
            auctions[dh].auctionEndTime = now + 10000;
            auctions[dh].highestBidder = msg.sender;
            auctions[dh].highestBid = msg.value;
            auctions[dh].exists = true;
            auctions[dh].ended = false;

            emit AuctionStarted(dh, _domain, msg.sender, msg.value);
            return;
        }


        //require(condition, message);(auctions[dh].ended)

        // Revert the call if the bidding period is over.
        require(now <= auctions[dh].auctionEndTime, "Auction already ended.");

        // If the bid is not higher, send the money back.
        require(msg.value > auctions[dh].highestBid, "There already is a higher bid.");

        if (auctions[dh].highestBid != 0) {
            // Let the recipients withdraw their money themselves with withdraw().
            auctions[dh].pendingReturns[auctions[dh].highestBidder] += auctions[dh].highestBid;
        }
        auctions[dh].highestBidder = msg.sender;
        auctions[dh].highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw(string memory _domain) public {
        bytes32 dh = hashDomain(_domain);

        // require(auctions[dh].exists, "No runnning auction for this domain.");

        // might not be so important?
        // No withdrawel during a running auction
        // require(auctions[dh].ended, "Auction still running.");

        uint amount = auctions[dh].pendingReturns[msg.sender];
        if (amount > 0) {
            // Set this to zero to prevent double spending.
            auctions[dh].pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }

    /// End the auction and send the highest bid to the beneficiary.
    function auctionEnd(bytes32 dHash) public {
        // 1. Conditions
        require(auctions[dHash].exists, "No such auction esists.");
        require(now >= auctions[dHash].auctionEndTime, "Auction not yet ended.");
        require(!auctions[dHash].ended, "auctionEnd has already been called.");

        // 2. Effects
        auctions[dHash].ended = true;
        emit AuctionEnded(auctions[dHash].highestBidder, auctions[dHash].highestBid);

        // 3. Interaction
        //address(this).transfer(auctions[dHash].highestBid);
    }


    function getAuctionStateBidder(string memory _domain) public view returns (address) {
        return (auctions[hashDomain(_domain)].highestBidder);
    }

    function getAuctionStateBid(string memory _domain) public view returns (uint256) {
        return (auctions[hashDomain(_domain)].highestBid);
    }

    function getAuctionStateExists(string memory _domain) public view returns (bool) {
        return (auctions[hashDomain(_domain)].exists);
    }

    function getAuctionStateReturns(string memory _domain) public view returns (uint256) {
        return (auctions[hashDomain(_domain)].pendingReturns[msg.sender]);
    }

}