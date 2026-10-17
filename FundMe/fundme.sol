// users fund
// withdraw fun
// minimum funding value in USD

Import {PriceConverter} from "./PriceConverter.sol"

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // public functon with payable keyword making it payable u know :))
    function fund() public payable {      
        require (msg.value.getConversionRate() > minimumUsd,"Didn't send enough ETH"); // 1ETH = 1e18 = 100000000000000000 wei
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }


    function withdraw() public {
        //for (/*starting index,ending index, step amount*/)
        for (uint256 funderIndex=0; funderIndex< funder.length; funderIndex = funderIndex +1){
            address funder = funders[funderIndex];
            addressToAmountFunded [funder] = 0;
        } /*U can use `funderIndex++` instead of `funderIndex = funderIndex +1`*/
        
        //resetting the
        funders = new address [](0);
    }

}
