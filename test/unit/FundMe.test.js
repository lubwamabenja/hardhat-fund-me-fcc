const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { assert, expect } = require("chai");

describe("FundMe", async function () {
  let fundMe;
  let deployer;
  let mockV3Aggregator;

  const sendValue = ethers.utils.parseEther("1"); //converts eth to WEI

  beforeEach(async function () {
    //getting Accounts
    // const accounts = await ethers.getSigners();

    //deploy our Fund me contract using hardhat deploy
    deployer = (await getNamedAccounts()).deployer;
    await deployments.fixture(["all"]); // deploy all contracts with all tags
    fundMe = await ethers.getContract("FundMe", deployer);
    mockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer);
  });

  //tests our constructors
  describe("constructor", async function () {
    it("sets the aggregator functions correctly", async function () {
      const response = await fundMe.priceFeed();
      assert.equal(response, mockV3Aggregator.address);
    });
  });

  //tests our constructors
  describe("fund", async function () {
    it("Fails if you dont send enought ETH", async function () {
      await expect(fundMe.fund()).to.be.revertedWith("Didnt send Enough");
    });

    it("Updated The amount funded Structure", async function () {
      console.log(sendValue.toString());
      await fundMe.fund({ value: sendValue });
      const response = await fundMe.addressToAmountFunded(deployer);
      console.log(response);
      assert.equal(response.toString(), sendValue.toString());
    });

    it("Adds funder to array of funders", async function () {
      await fundMe.fund({ value: sendValue });
      const funder = await fundMe.funders(0);
      assert.equal(funder, deployer);
    });
  });
});
