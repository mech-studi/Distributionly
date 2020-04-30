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

        AssertBool.isFalse(
            keeper.getAuctionStateExists(domain),
            "Auction should no exists at the beginning"
        );

        // address(keeper).call.gas(500000).value(3)("bid", [domain]);
        // keeper.bid.gas(220000).value(3);\
        keeper.bid.value(3)(domain);

        AssertBool.isTrue(
            keeper.getAuctionStateExists(domain),
            "Auction must exists after first bid."
        );

        AssertUint.equal(
            keeper.getAuctionStateBid(domain),
            3,
            "Curent bid should be 3."
        );
    }

    function testHigherBid() public {
        DomainKeeper keeper = new DomainKeeper();

        string memory domain = "test.test";

        AssertBool.isFalse(
            keeper.getAuctionStateExists(domain),
            "Auction should no exists at the beginning"
        );

        // address(keeper).call.gas(500000).value(3)("bid", [domain]);
        // keeper.bid.gas(220000).value(3);\
        keeper.bid.value(1)(domain);
        keeper.bid.value(2)(domain);

        AssertBool.isTrue(
            keeper.getAuctionStateExists(domain),
            "Auction must exists after first bid."
        );

        AssertUint.equal(
            keeper.getAuctionStateBid(domain),
            2,
            "Curent highest bid should be 2."
        );
    }
}
