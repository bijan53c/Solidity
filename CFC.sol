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


  event Transfer(address indexed from, address indexed to, uint256 value);

  function transfer(address to, uint256 amount) external returns (bool) {
    require(balances[msg.sender] >= amount, "Not enough CoffeeCoin");
    balances[msg.sender] -= amount;
    balances[to] += amount;
    emit Transfer(msg.sender, to,amount);
    return true;
  }
}
