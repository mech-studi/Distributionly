var DomainKeeperContract = artifacts.require("./DomainKeeper.sol");

module.exports = function(deployer) {
    deployer.deploy(DomainKeeperContract);
};
