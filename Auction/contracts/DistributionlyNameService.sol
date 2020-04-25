pragma solidity >=0.4.25 <0.7.0;


contract DistributionlyNameService {

    address public serviceOwner;

    struct MgntDomain {
        string dName;
        address dOwner;
        string ipv4;
        uint256 priceInWei;
        bool isManaged;
    }

    mapping(bytes32 => MgntDomain) public domains;

    function hashDomain(string memory domain) private pure returns (bytes32)  {
        return keccak256(abi.encodePacked(domain));
    }

    function requestDomain(string memory domain) public payable {
        bytes32 dHash = hashDomain(domain);
        domains[dHash] = MgntDomain(domain, msg.sender, "", msg.value, true);
    }

    function checkDomainAvailability(string memory domain) public view returns (bool) {
        return domains[hashDomain(domain)].isManaged;
    }

    function resolveDomain(string memory domain) public view returns (string memory) {
        bytes32 dHash = hashDomain(domain);
        MgntDomain storage d = domains[dHash];onlyOwner
        if(d.isManaged) {
            return d.ipv4;
        }
        return "unknown";
    }

}
