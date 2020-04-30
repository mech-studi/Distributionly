pragma solidity 0.5.1;


contract DomainKeeper {
    uint256 counter = 0;
    mapping(uint256 => iDomain) domains;
    struct iDomain {
        uint256 _id;
        string owner;
        uint256 endcontract;
        string domainname;
    }
    // the event is going to show which damain is close to be free and preparing for a new auction
    event DomainFree(uint256 endcontract, string domainname);

    // use the index in domain (more expensive for gas but not everyone may interesting in the same domain)

    // function to add new ipaddress:
    function addDomain(string memory _owner, string memory _domainame) public {
        if (!alreadyregister(_domainame)) {
            counter += 1;
            domains[counter] = iDomain(counter, _owner, now, _domainame);
        }
        // what happen if the ip is alreadyregister??
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
>
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
    //}
}
