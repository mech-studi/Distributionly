pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SimpleAuction.sol";


contract TestSimpleAuctionTest {
    // Truffle looks for `initialBalance` when it compiles the test suite
    // and funds this test contract with the specified amount on deployment.
    uint256 public initialBalance = 10 ether;

    function testUndeployedContract() public {
        SimpleAuction auction = new SimpleAuction();

        uint256 expected = 10000;

        Assert.equal(
            auction.getAuctionEndTime(),
            expected,
            "should be endtim xy"
        );
    }

    function testInitialBalanceUsingDeployedContract() public {
        //SimpleAuction auction = SimpleAuction(
        //   DeployedAddresses.SimpleAuction()
        //);
      
        SimpleAuction auction = new SimpleAuction();
        //Assert.equal(address(auction).balance, 0, "should be 0");
    

      auction.bid.value(1 wei)();
      Assert.equal(auction.highestBid(), 2 wei, "highest bid should be 1 wei");
 // Assert.equal(auction.balance(this), 20 wei, "Donator balance is different than sum of donations");

       // auction.bid.call().then(function(result) {
  //result.tx => transaction hash, string
  // result.logs => array of trigger events (1 item in this case)
  // result.receipt => receipt object
//});
        //address(auction.bid).call({from:address(this), value:1});
        //Assert.equal(address(auction).balance, 5000 wei);

        // perform an action which sends value to myContract, then assert.
        //auction.bid();
    }
}

