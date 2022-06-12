const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config.ts");
const { network } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  // extracting from the hardhat run time enviroment hre
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  //   const ethUsdPriceFeedAddress = networkConfig[chainID]["ethUsdPriceFeed"];

  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    //if we are on a local chain, we use the pricefeed of the Mock Aggregator
    const ethUsdAggregator = await deployments.get("MockV3Aggregator"); //get the interface
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    console.log("chainid", chainId);
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }

  let args = [ethUsdPriceFeedAddress];
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  //Verifying Our Contracts
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, args);
  }
};

module.exports.tags = ["all", "fundMe"];
