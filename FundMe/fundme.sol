// users fund
// withdraw fun
// minimum funding value in USD



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FundMe {

    uint256 public minimumUsd = 5;

    // public functon with payable keyword making it payable u know :))
    function fund() public payable {
        //minimum 5 $
        //Lets user to send amounts with the message sending
        require (msg.value > minimumUsd,"Didn't send enough ETH"); // 1ETH = 1e18 = 100000000000000000 wei
    }

    function withdraw() public{}

    function calculate() public{}
}
