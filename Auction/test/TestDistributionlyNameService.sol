import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DistributionlyNameService.sol";
import "../contracts/DistributionlyNameAuction.sol";


contract TestDistributionlyNameService {
    // Truffle looks for `initialBalance` when it compiles the test suite
    // and funds this test contract with the specified amount on deployment.
    uint256 public initialBalance = 10 ether;

    function testAuctionStart() public {
        DistributionlyNameService service = new DistributionlyNameService();

        string memory domain = "test.test";
        address auctionAddress = service.startDomainAuction(domain);

        AssertAddress.isNotZero(
            auctionAddress,
            "Should return an auction address"
        );
    }

    function testRequestDomain() public {
        DistributionlyNameService service = new DistributionlyNameService();

        string memory domain = "test.test";
        bytes32 domainHash = service.requestDomain(domain);

        string memory d = service.resolveDomain(domain);

        AssertString.equal(d, domain, "should return givne domain name.");

        // AssertString.equal(service.domains()[domainHash].ipv4, "d", "Should have ipv4 value");

        // AssertBytes32.equal(domainHash, keccak256(abi.encodePacked("dd")), "Incorrect domain hash.");

       
    }
}
