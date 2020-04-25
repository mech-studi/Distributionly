pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SimpleAuction.sol";


contract TestSimpleAuctionTest {
  
    // Truffle looks for `initialBalance` when it compiles the test suite
    // and funds this test contract with the specified amount on deployment.
    uint256 public initialBalance = 10 ether;

    // function testUndeployedContract() public {
    //     SimpleAuction auction = new SimpleAuction();

    //     uint256 expected = 10000;

    //     Assert.equal(
    //         auction.getAuctionEndTime(),
    //         expected,
    //         "should be endtim xy"
    //     );
    // }

    function testFirstBid() public {
      SimpleAuction auction = new SimpleAuction();

      auction.bid.value(1 wei)();
      Assert.equal(auction.highestBid(), 1 wei, "highest and first bid should be 1 wei");
    }

    function testMultipleBids() public {
      SimpleAuction auction = new SimpleAuction();

      auction.bid.value(1 wei)();
      auction.bid.value(2 wei)();
      auction.bid.value(3 wei)();
      Assert.equal(auction.highestBid(), 3 wei, "highest bid should be 3 wei");
    }
}

