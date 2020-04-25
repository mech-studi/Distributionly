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
}
