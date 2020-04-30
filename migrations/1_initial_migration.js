const Migrations = artifacts.require("Migrations");
const DomainKeeper = artifacts.require("DomainKeeper");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(DomainKeeper);
};
