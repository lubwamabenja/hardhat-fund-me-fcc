//Get Funds From Users
//Withdraw Funds from the contract
//Set a minimum funding value in USD

//++++++++++++++++MISSED SECTIONS +++++++++++++++
//Writing Tests
//Storage and Gas optimization

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;
import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./PriceConverter.sol";
//change Require to review to optimise the gas
error FundMe_NotOwner();

/**
Nutspec Format for creating Documentation
@title A contract for crowd Funding
@author Lubwama Isaac
@notice This contract is to demo a funding contract
@dev This implements Price feeds as our library

 */

contract FundMe {
    //all functions of the library are attached to the type uint256
    //so now we can call the function like uint256.getConversionRate()

    //Type Decalarations
    using PriceConverter for uint256;

    //State Variables
    uint256 public constant MINIMUM_USD = 1 * 10**18;
    //List of Funders
    address[] private funders;
    //mappings
    mapping(address => uint256) private addressToAmountFunded;
    address private immutable i_owner;
    //chainlink address for different chains
    AggregatorV3Interface private priceFeed;

    //Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner,"Sender is not the owner");
        //Gas Efficient

        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress); //combining interface or abi with address you get a contract;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        console.log("sent", msg.value.getConversionRate(priceFeed));
        console.log("minimum", MINIMUM_USD);
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didnt send Enough"
        ); //1e18 = 1*10**18;
        //a ton of computation here
        //what is reverting
        //undo any action before,and send remaining gas back

        //add funders to an array

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    //Withdraw Funds

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            //code
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reseting the array to size zero
        funders = new address[](0);

        //Two Ways of Withdrawing Ether
        //Transfer Function
        //Automaticall reverts the gas fee if the transaction fails the money
        //We transfer money to a payable address

        // payable(msg.sender).transfer(address(this).balance);

        //Send Function
        //Send function does not revert the money if the transfer fails
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send Failed");

        //Call Function
        //The best way to send and recieve

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    //What happens when someone sends us money without calling the fund function;
    //recieve
    //fallback

    //0.18450726

    //0.18447576

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }
}
