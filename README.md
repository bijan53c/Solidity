# Solidity
Public Solidity learning journal — from basics to Web3 security research

# Ticket.sol
> It's a simple scenario for basic solidity training

Imagine there's an event with limited tickets to sell.
- Owner can add tickets to sell
- People can check how many is available
- They can buy tickets
- Other people than the owner can't create tickets
- On the payment (imaginary price of 0.01 ETH)
  - But if the request is wrong not equal to the set price, contract won't work
  - No underpayment neither an overpayment

This is what this contract do so far.

------
