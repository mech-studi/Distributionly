pragma solidity >=0.5.0 <0.7.0;


contract DomainKeeper {
    //struct to keep all the data of the registered domains:
    struct iDomain {
        address owner;
        uint256 endcontract;
        string domainname;
        string Ipv4;
        string Ipv6;
    }

    mapping(bytes32 => iDomain) domains;

    /// Function the user will call to modify the IPS
    /// Only the owner of the domain is Allowed to change this information.
    function ConfigureDomain(string memory _domainame, string memory _Ipv4, string memory _Ipv6) public payable {
        //require(condition, message);(auctions[dh].owner== msg....
        bytes32 dh = hashDomain(_domainame);
        require(bytes(domains[dh].domainname).length != 0, "not domain register with that name");
        require(domains[dh].owner == msg.sender, "Error, you are not the owner of this domain");
        domains[dh].Ipv4 = _Ipv4;
        domains[dh].Ipv6 = _Ipv6;
    }

    /// Function that retunrs the information about a especifict domain
    function getDomainInfo(string memory _domainame)
        public
        view
        returns (string memory ipv4, string memory ipv6, address owner, uint256 _endcontract)
    {
        bytes32 dh = hashDomain(_domainame);
        require(bytes(domains[dh].domainname).length != 0, "not domain register with that name");
        return (domains[dh].Ipv4, domains[dh].Ipv6, domains[dh].owner, domains[dh].endcontract);
    }

    /// The claim methos is gonna save the new domains with the respective owner.
    function claim(string memory _domainame) public payable {
        bytes32 dh = hashDomain(_domainame);
        require(auctions[dh].highestBidder == msg.sender, "You are not the owner of this domain");
        domains[dh].domainname = _domainame;
        domains[dh].owner = msg.sender;
    }

    /// This function is here only for checking the code works:
    function addDomain(string memory _domainame, address _owner) public {
        bytes32 dh = hashDomain(_domainame);
        domains[dh].domainname = _domainame;
        domains[dh].owner = _owner;
    }

    /// Retunrs the address of the owner of a domain:
    function getOwner(string memory _domainame) public view returns (address) {
        bytes32 dh = hashDomain(_domainame);
        require(bytes(domains[dh].domainname).length != 0, "not domain register with that name");
        return domains[dh].owner;
    }

    // ========================================================
    // AUCTION STUFF
    // Based on: https://solidity.readthedocs.io/en/v0.6.6/solidity-by-example.html#simple-open-auction
    // ========================================================

    struct iAuction {
        uint256 auctionEndTime;
        address highestBidder;
        uint256 highestBid;
        mapping(address => uint256) pendingReturns; // Allowed withdrawals of previous bids
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
            auctions[dh].auctionEndTime = now + 1 minutes;
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

        uint256 amount = auctions[dh].pendingReturns[msg.sender];
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

    /// Lets you check the state of an auction and returns the following attributes:
    /// - Domain
    /// - Address of highest bidder
    /// - Amount of the highest bid
    /// - Auction end time
    /// - Flag indicating if ended or not
    /// - Flag indicating if exists or not
    function getAuctionState(string memory _domain) public view returns (string memory, address, uint256, uint256, bool, bool) {
        bytes32 dh = hashDomain(_domain);
        return (
            _domain, 
            auctions[dh].highestBidder,
            auctions[dh].highestBid, 
            auctions[dh].auctionEndTime, 
            auctions[dh].ended,
            auctions[dh].exists
        );
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
