const SimpleAuction = artifacts.require("SimpleAuction");
const DistributionlyNameService = artifacts.require("DistributionlyNameService");
const DistributionlyNameAuction = artifacts.require("DistributionlyNameAuction");

module.exports = function (deployer) {
  deployer.deploy(SimpleAuction);
  deployer.deploy(DistributionlyNameService);
  //deployer.deploy(DistributionlyNameAuction);
};
