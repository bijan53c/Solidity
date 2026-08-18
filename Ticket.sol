// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
  uint256 private count;
  
  address public owner;

  uint256 public ticketPrice = 0.01 ether; //Finney 10

  function increment() external onlyOwner{
    count += 1;
  }

  function getCount() external view returns (uint256) {
    return count;
  }

  function decrement() external payable {
    require(count > 0, "Sold out");
    require(msg.value == ticketPrice, "Wrong payment amount");
    count -= 1;
  }


  

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not the venue");
    _;
  }

  function withdraw() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool success, ) = owner.call {value: amount}("");
    require(success, "withdraw failed");
  }


}

