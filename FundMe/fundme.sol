// users fund
// withdraw fun
// minimum funding value in USD

import {PriceConverter} from "./PriceConverter.sol";

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
        for (uint256 funderIndex=0; funderIndex< funders.length; funderIndex = funderIndex +1){
            address funder = funders[funderIndex];
            addressToAmountFunded [funder] = 0;
        } /*U can use `funderIndex++` instead of `funderIndex = funderIndex +1`*/
        
        //resetting the
        funders = new address [](0);



    //transfer :: gas>2300 => throws error
    //send :: gas>2300 => throws boolean
    //call :: forward all gas or set gas, return bool

    //msg.sender = address type
    //payable(message.sender) = payable address
    //so we do a type cast here to be able to pay 
    //payable(msg.sender).transfer(address(this).balance);
    //this points to the contract (this contract) so we take the balance in this contract

    //Send
    //bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //require(sendSuccess, "Send Failed")
    //Since send returns a boolean only and does not revert transaction on fail and the require statement reverts in case of failure

    //call : first lower level command in sol. It can call any function in whole ethereum
    (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}(/*any function u wanna call but we use blank*/""); //we know funciton returns 2 variables but we only care about 1 (the callSuccess)
    require (callSuccess, "call failed");

    }


}
