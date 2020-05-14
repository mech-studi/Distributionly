pragma solidity >=0.5.0 <0.7.0;


contract DomainKeeper {

    //struct to keep all the data of the registered domains:
    struct iDomain {
        address owner;
        string domainname;
        string Ipv4;
        string Ipv6;
        bool exists;
    }

    mapping(bytes32 => iDomain) domains;


    /// Single place to do the domain name hashing.
    function hashDomain(string memory domain) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(domain));
    }

    /// Figures out the current state of a domain
    /// Possible states are: registered, inauction or free
    function calcDomainState(bytes32 dHash) private view returns (string memory) {
        if(domains[dHash].exists && domains[dHash].owner != address(0)) {
            return "registered";
        } else if(!domains[dHash].exists && auctions[dHash].exists && now <= auctions[dHash].auctionEndTime) {
            return "inauction";
        } else if(!domains[dHash].exists && auctions[dHash].exists && now > auctions[dHash].auctionEndTime) {
            return "toberegistered";
        } else{
            return "free";
        }
    }

    /// Function the user will call to modify the IPS
    /// Only the owner of the domain is Allowed to change this information.
    function configureDomain(string memory _domainame, string memory _Ipv4, string memory _Ipv6) public payable {
        bytes32 dh = hashDomain(_domainame);

        require(domains[dh].exists, "Domain does not exist.");
        require(keccak256(abi.encodePacked(calcDomainState(dh))) == keccak256(abi.encodePacked("registered")), "Domain is not yet registered.");
        require(domains[dh].owner == msg.sender, "Error, you are not the owner of this domain");

        domains[dh].Ipv4 = _Ipv4;
        domains[dh].Ipv6 = _Ipv6;
    }

    /// Function that retunrs the information about a especifict domain
   function getDomainInfo(string memory _domainame) public view returns (string memory state, string memory ipv4, string memory ipv6, address owner) {
        bytes32 dh = hashDomain(_domainame);
        return (calcDomainState(dh), domains[dh].Ipv4, domains[dh].Ipv6, domains[dh].owner);
    }

    /// The claim method is ending the auction and registers the domain name with the owner.
    function claim(string memory _domainame) public returns (bool) {
        bytes32 dh = hashDomain(_domainame);

        require(auctions[dh].exists, "No existing auction for wanted domain.");
        require(auctions[dh].highestBidder == msg.sender, "You are not the winner of the auction.");
        require(now >= auctions[dh].auctionEndTime, "Auction is still running.");
        require(!auctions[dh].claimed, "Auction is already claimed.");

        // End Auction
        auctions[dh].claimed = true;
        emit AuctionEnded(_domainame, auctions[dh].highestBidder, auctions[dh].highestBid);

        // Register Domain
        domains[dh].domainname = _domainame;
        domains[dh].owner = msg.sender;
        domains[dh].exists = true;

        // Return pendingReturns
        uint256 amount = auctions[dh].pendingReturns[msg.sender];
        if (amount > 0) {
            auctions[dh].pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                auctions[dh].pendingReturns[msg.sender] = amount;
                return false;
            }
            emit Withdraw(_domainame, msg.sender, amount);
        }

        return true;
    }

    // ========================================================
    // AUCTION STUFF
    // Based on: https://solidity.readthedocs.io/en/v0.6.6/solidity-by-example.html#simple-open-auction
    // ========================================================

    uint constant AUCTION_MIN_PRICE_IN_WEI = 5000000000000000000; // is 5 Ether
    uint constant AUCTION_DURATION = 1 minutes;
    uint constant AUCTION_EXTENSION_TIME = 20 seconds;

    struct iAuction {
        uint256 auctionEndTime;
        address highestBidder;
        uint256 highestBid;
        mapping(address => uint256) pendingReturns; // Allowed withdrawals of previous bids
        bool claimed;
        bool exists;
    }

    mapping(bytes32 => iAuction) auctions;

    // Auction Events
    event AuctionStarted(string domain, bytes32 dHash, address account, uint256 amount);
    event AuctionEnded(string domain, address winner, uint256 amount);
    event AuctionExtended(string domain, uint extensionTime, uint newEndTime);
    event HighestBidIncreased(string domain, address bidder, uint256 amount);
    event Withdraw(string domain, address bidder, uint256 amount);


    /// Bid on the auction with the value sent together with this transaction.
    /// The value will only be refunded if the auction is not won.
    function bid(string memory _domain) public payable {
        bytes32 dh = hashDomain(_domain);

        // Check min bid value.
        require(AUCTION_MIN_PRICE_IN_WEI <= msg.value, "Minimum bid for an auction is 5 Ethers.");

        // Check domain state, cannot be registered domain.
        require(keccak256(abi.encodePacked(calcDomainState(dh))) != keccak256(abi.encodePacked("registered")), "Domain is not free for auction.");

        // create new auction if no entry is available.
        if (!auctions[dh].exists) {
            auctions[dh].auctionEndTime = now + AUCTION_DURATION;
            auctions[dh].highestBidder = msg.sender;
            auctions[dh].highestBid = msg.value;
            auctions[dh].exists = true;
            auctions[dh].claimed = false;

            emit AuctionStarted(_domain, dh, msg.sender, msg.value);
            return;
        }

       // Revert if auction already ended
        require(now <= auctions[dh].auctionEndTime, "Action already ended.");

        // Extend auction.
        if(now + AUCTION_EXTENSION_TIME >= auctions[dh].auctionEndTime){
            extendAuction(_domain, AUCTION_EXTENSION_TIME);
        }

        // If the bid is not higher, send the money back.
        require(msg.value > auctions[dh].highestBid, "There already is a higher bid.");

        if (auctions[dh].highestBid != 0) {
            // Let the recipients withdraw their money themselves with withdraw().
            auctions[dh].pendingReturns[auctions[dh].highestBidder] += auctions[dh].highestBid;
        }
        auctions[dh].highestBidder = msg.sender;
        auctions[dh].highestBid = msg.value;

        emit HighestBidIncreased(_domain, msg.sender, msg.value);
    }

    /// Withraw obsolete bids.
    /// Bids that are overbidden can be collected back by the bidder.
    function withdraw(string memory _domain) public returns (bool)  {
        bytes32 dh = hashDomain(_domain);

        require(auctions[dh].exists, "No existing auction for wanted domain.");

        uint256 amount = auctions[dh].pendingReturns[msg.sender];
        if (amount > 0) {
            auctions[dh].pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                auctions[dh].pendingReturns[msg.sender] = amount;
                return false;
            }

            emit Withdraw(_domain, msg.sender, amount);
        }
        return true;
    }

    /// Extend the auction time by the given time.
    function extendAuction(string memory _domain, uint _extensionTime) internal {
        bytes32 dh = hashDomain(_domain);

        // 1. Conditions
        require(auctions[dh].exists, "No existing auction for wanted domain.");
        require(now <= auctions[dh].auctionEndTime, "Auction not yet ended.");

        // 2. Effects
        auctions[dh].auctionEndTime += _extensionTime;
        emit AuctionExtended(_domain, _extensionTime, auctions[dh].auctionEndTime);
    }

    /// Lets you check the state of an auction and returns the following attributes:
    /// - Domain
    /// - Address of highest bidder
    /// - Amount of the highest bid
    /// - Auction end time
    /// - Flag indicating if domain was claimed or not
    /// - Flag indicating if exists or not
    /// - Flag indicating if caller has pending returns
    function getAuctionState(string memory _domain) public view returns (string memory domain, address higestBidder, uint256 highestBid, uint256 auctionEndTime, bool claimed, bool exists, bool accountHasReturns) {
        bytes32 dh = hashDomain(_domain);

        bool hasReturns = false;
        if(auctions[dh].pendingReturns[msg.sender] > 0 ) {
            hasReturns = true;
        }

        return (
            _domain,
            auctions[dh].highestBidder,
            auctions[dh].highestBid, 
            auctions[dh].auctionEndTime,
            auctions[dh].claimed,
            auctions[dh].exists,
            hasReturns
        );
    }

     function getAuctionStateReturns(string memory _domain) public view returns (uint256) {
         return (auctions[hashDomain(_domain)].pendingReturns[msg.sender]);
     }

}
