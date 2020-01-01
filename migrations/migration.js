const SimpleToken = artifacts.require("./SimpleToken.sol");

module.exports = (deployer) => {
  deployer.deploy(TokenReward, "BloceducareToken", "BET", 18, 1000000);
};