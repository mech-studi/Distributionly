import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DomainKeeper.sol";


contract TestDomainKeeper {

    // Truffle looks for `initialBalance` when it compiles the test suite
    // and funds this test contract with the specified amount on deployment.
    uint256 public initialBalance = 10 ether;

    function testInitialBid() public {
        DomainKeeper keeper = new DomainKeeper();

        string memory domain = "test.test";
        keeper.bid(domain);
    }

}
