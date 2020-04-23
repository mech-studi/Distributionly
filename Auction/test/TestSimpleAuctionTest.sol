pragma solidity >=0.4.25 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SimpleAuction.sol";

contract TestSimpleAuctionTest {

  function testInitialBalanceUsingDeployedContract() public {
    SimpleAuction auction = new SimpleAuction(100);

    uint expected = 10000;

    Assert.equal(auction.getAuctionEndTime(), expected, "should be endtim xy");
  }


}
