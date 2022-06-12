// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface version = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        return version.version();
    }

    function getPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        //This is the price of ETH in USD
        //It will have 8 decimal places so we need to convert it to 18
        //Then typecasting
        return uint256(price * 1e10); //10000000000
    }

    function getConversionRate(uint256 _amount, AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 rate = getPrice(priceFeed);
        uint256 ethAmountInUsd = (rate * _amount) / 1e18; //it would have 36 decimals so we reduce to 18
        return ethAmountInUsd;
    }
}
