const { network } = require("hardhat");
const {
  developmentChains,
  DECIMALS,
  INITIAL_ANSWER,
} = require("../helper-hardhat-config.ts");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainID = network.config.chainID;

  //If chains dont have price feeds , deploy the Mock contracts//dummy
  if (developmentChains.includes(network.name)) {
    log("local network detected ,Deploying Mocks.......");
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      log: true,
      from: deployer,
      args: [DECIMALS, INITIAL_ANSWER],
    });
    log("MOCKS DEPLOYED");
    log("================================================");
  }
};

module.exports.tags = ["all", "mocks"]; // hardhat will run a script with special tags  --tags mocks
