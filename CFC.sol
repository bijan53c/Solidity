// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CoffeeCoin {
  string public name = "CoffeeCoin";
  string public symbol = "CFC";

  mapping(address => uint256) public balances;

  uint public totalSupply;

  constructor(uint initialSupply) {
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
  }
}