# Solidity
Public Solidity learning journal — from basics to Web3 security research

# CFC.sol 19.08.2026
Basic solidity based token on ERC20 standard and a work at hand
Imagine a coffee shop with a blockchain based loyalty points. So this token is that imaginary dream coffee shop loyalty point OK?
*So it's **Coffee Coin** aka **CFC***
The owner deploys and mints total tokens at same point and start of the job.
Currently it is not done yet but... The goal is to:
- [x] Show CFC balance of each wallet
- [ ] Send other wallets (Customers) CFC transaction
- [ ] Other wallets (customers/users) can send CFC to any other wallet
  - Which can mean to use their loyalty points
  - or send it to friend of theirs

# Ticket.sol 18.08.2026
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

*18.08.2026 change*
- Added withdraw function, now owner can withdraw the made balance from the contract

------
