const SimpleAuction = artifacts.require("SimpleAuction");

module.exports = function(deployer) {
  deployer.deploy(SimpleAuction);
};
