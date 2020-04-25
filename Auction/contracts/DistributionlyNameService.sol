pragma solidity >=0.5.0 <0.7.0;

import "./DistributionlyNameAuction.sol";

contract DistributionlyNameService {

    address public serviceOwner;

    struct MgntDomain {
        string dName;
        address dOwner;
        string ipv4;
        uint256 priceInWei;
        bool isManaged;
    }

    mapping(bytes32 => address) public auctions;

    mapping(bytes32 => MgntDomain) public domains;

    constructor() public {}

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
        MgntDomain storage d = domains[dHash];
        if(d.isManaged) {
            return d.ipv4;
        }
        return "unknown";
    }

    function startDomainAuction(string memory domain) public returns (address) {
        bytes32 dHash = hashDomain(domain);
        DistributionlyNameAuction auction = new DistributionlyNameAuction(address(this), 10000000, address(uint160(address(this))));
        auctions[dHash] = address(auction);
        return auctions[dHash];
    }




}
