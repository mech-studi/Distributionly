pragma solidity >=0.5.1 <0.7.0;

contract DomainKeeper {
    struct iDomain {
        uint256 _id;
        string owner;
        string domainname;
        uint256 endcontract;
    }

    uint256 counter = 0;

    mapping(uint256 => iDomain) public domains;

    // the event is going to show which damain is close to be free and preparing for a new auction
    event DomainFree(uint256 endcontract, string domainname);

    // use the index in domain (more expensive for gas but not everyone may interesting in the same domain)

    // function to add new ipaddress:
    function addDomain(string memory _owner, string memory _domainame) public {
        if (!alreadyregister(_domainame)) {
            counter += 1;
            domains[counter] = iDomain({
                _id: counter,
                owner: _owner,
                domainname: _domainame,
                endcontract: now
            });
        }
        // what happen if thauctions[dh]e ip is alreadyregister??
        //create and event to inform when is gonna be free again?
    }

    function getOwner(uint256 id) public view returns (string memory) {
        return domains[id].owner;
    }

    function getAdress(uint256 id) public view returns (string memory) {
        return domains[id].domainname;
    }

    // function to checked if the ip is already in our register
    function alreadyregister(string memory newDomain)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i <= counter; i++) {
            string memory s1 = domains[i].domainname;
            if (
                keccak256(abi.encodePacked(newDomain)) ==
                keccak256(abi.encodePacked(s1))
            ) {
                return true;
            }
        }
        return false;
    }

    function compareStringsbyBytes(string memory s, uint256 index)
        public
        view
        returns (bool)
    {
        string memory s1 = domains[index].domainname;
        if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked(s1))) {
            return true;
        }
        return false;
    }

    function dateclosetofinish(uint256 index) external {
        if (domains[index].endcontract == now) {
            emit DomainFree(
                domains[index].endcontract,
                domains[index].domainname
            );
        }
    }

    //function hasheverything(string memory _owner, string memory  _domainame) public returns(bytes32){
    //    counter += 1;
    //    domains[counter] = iDomain(counter,_owner,now, _domainame);
    //    iDomain memory message = domains[counter] ;
    //    return keccak256(abi.encode(message._id, message.owner,message.endcontract, message.domainname));
    //}auctions[dh]

    // ========================================================
    // Auction stuff
    // ========================================================

    struct iAuction {
        uint256 auctionEndTime;
        // Current state of the auction.
        address highestBidder;
        uint256 highestBid;
        // Allowed withdrawals of previous bids
        //mapping(address => uint256) pendingReturns;
        // Set to true at the end, disallows any change.
        // By default initialized to `false`.
        //bool ended;
        bool exists;
    }

    mapping(bytes32 => iAuction) auctions;
    //mapping(bytes32 => address[]) pendingReturns;

    // Auction Events.auctions[dh]
    event AuctionStarted(
        bytes32 dHash,
        string domain,
        address account,
        uint256 amount
    );
    event AuctionEnded(address winner, uint256 amount);
    event HighestBidIncreased(address bidder, uint256 amount);

    // Single place to do the domain name hashing.
    function hashDomain(string memory domain) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(domain));
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid(string memory _domain) public payable {
        bytes32 dh = hashDomain(_domain);

        // create new auction if no entry is available.
        if (!auctions[dh].exists) {
            // address[] memory emptyReturns;

            // iAuction memory add = iAuction({
            //     auctionEndTime: now + 10000,
            //     highestBidder: msg.sender,
            //     highestBid: msg.value,
            //     ended: false
            // });

            auctions[dh].auctionEndTime = now + 10000;
            auctions[dh].highestBidder = msg.sender;
            auctions[dh].highestBid = msg.value;
            auctions[dh].exists = true;
            // auctions[dh].ended = false;

            emit AuctionStarted(dh, _domain, msg.sender, msg.value);
            return;
        }

        // Revert the call if the bidding
        // period is over.
        require(now <= auctions[dh].auctionEndTime, "Auction already ended.");

        // If the bid is not higher, send the
        // money back (the failing require
        // will revert all changes in this
        // function execution including
        // it having received the money).
        require(
            msg.value > auctions[dh].highestBid,
            "There already is a higher bid."
        );

        if (auctions[dh].highestBid != 0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
            //auctions[dh].pendingReturns[auctions[dh]
             //  .highestBidder] += auctions[dh].highestBid;
        }
        auctions[dh].highestBidder = msg.sender;
        auctions[dh].highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function getAuctionState(string memory _domain)
        public
        view
        returns (uint256)
    {
        bytes32 dh = hashDomain(_domain);
        // iAuction memory a = auctions[dh];
        return (auctions[dh].highestBid);
    }
}
