pragma solidity >=0.5.0 <0.7.0;

import "./DistributionlyNameAuction.sol";

contract DistributionlyNameService {

    address public serviceOwner;

    // struct MgntDomain {
    //     string dName;
    //     address dOwner;
    //     string ipv4;
    //     uint256 priceInWei;
    //     bool isManaged;
    // }

    //mapping(bytes32 => DistributionlyNameAuction) public auctions;

    // mapping(bytes32 => MgntDomain) public domains;

    mapping(bytes32 => address) domains;

    event DomainStored(bytes32 hash, string domainName);

    function hashDomain(string memory domain) private pure returns (bytes32)  {
        return keccak256(abi.encodePacked(domain));
    }

    // function requestDomain(string memory domain) public payable returns (bytes32) {
    //     bytes32 dHash = hashDomain(domain);
    //     //domains[dHash] = MgntDomain(domain, msg.sender, "", msg.value, true);
    //     domains[dHash].dName = domain;
    //     domains[dHash].dOwner = msg.sender;
    //     domains[dHash].ipv4 = "fake ip";
    //     domains[dHash].priceInWei = msg.value;
    //     domains[dHash].isManaged = true;

    //     emit DomainStored(dHash, domain);

    //     return dHash;
    // }

    // function checkDomainAvailability(string memory domain) public view returns (bool) {
    //     return domains[hashDomain(domain)].isManaged;
    // }

    function resolveDomain(string memory domain) public view returns (address) {
        bytes32 dHash = hashDomain(domain);
        // MgntDomain storage d = domains[dHash];
        // if(d.isManaged) {
        //     return d.ipv4;
        // }

        return domains[dHash];
    }

    function startDomainAuction(string memory domain) public payable returns (address) {
        bytes32 dHash = hashDomain(domain);
        DistributionlyNameAuction auction = new DistributionlyNameAuction(10000000, address(uint160(address(this)), domain, msg.sender));
        //ddress(auction).transfer(msg.value);

        domains[dHash] = address(auction);
        return domains[dHash];
    }


}
