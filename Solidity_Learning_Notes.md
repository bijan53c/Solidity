# Solidity Learning Notes — From First Experiments to Smart-Contract Patterns

> A practical learning journal based on my Solidity practice repository: [bijan53c/Solidity](https://github.com/bijan53c/Solidity).
>
> These notes explain the ideas behind the exercises in plain language, including what each step teaches, why it matters, and what to watch out for. The code in the repository is a learning record, not an audit or a claim that every example is production-ready.

## How to use these notes

There are two ways to follow this repository:

1. **Historical route:** read the exercises in the order I worked on them. This shows how the ideas developed over time.
2. **Learning route:** use the roadmap near the end. It rearranges the same ideas from simpler concepts to more complex ones, because the date I wrote a contract is not necessarily the best order in which to learn it.

When reading code, ask three questions:

- **What state does this contract store?**
- **Who is allowed to change that state?**
- **What assumptions must be true for each function to be safe?**

---

# Part I — My learning timeline

## 1. `CFC.sol` — Coffee Coin
**Date in repository notes:** 19 August 2026  
**Level:** Beginner / token-transfer fundamentals  
**Source:** [`CFC.sol`](https://github.com/bijan53c/Solidity/blob/main/CFC.sol)

### The idea

Coffee Coin (`CFC`) is a small token experiment based on a coffee shop's loyalty points. The owner starts with a supply of tokens, and users can transfer those tokens to other addresses.

This is a useful first look at token-like behavior: balances are associated with addresses, and a transfer moves value from one balance to another.

### Main concepts

- **State variables:** `name`, `symbol`, `balances`, and `totalSupply` live in contract storage.
- **Mappings:** `mapping(address => uint256)` associates each wallet address with a token balance.
- **Constructor:** runs once when the contract is deployed. Here it assigns the initial supply to the deploying address.
- **`msg.sender`:** the address making the current call.
- **`require`:** checks a condition and reverts the transaction if it is false.
- **Events:** `Transfer` emits a log that external applications can listen for.
- **Arithmetic and state updates:** subtract from the sender and add to the recipient.

### The transfer flow

The contract's `transfer(to, amount)` function follows this logic:

1. Check that the sender has at least `amount`.
2. Subtract the amount from the sender's balance.
3. Add the amount to the recipient's balance.
4. Emit a `Transfer` event.
5. Return `true`.

The balance check prevents a user from transferring more tokens than they own. With Solidity 0.8.x, arithmetic underflow and overflow also revert by default, but explicit checks can make the intended rule clearer.

### Important distinction: a token-like contract versus ERC-20

This exercise demonstrates the basic mechanics of a token, but it is **not yet a complete ERC-20 implementation**. An ERC-20-compatible token normally exposes the standard interface and behavior, including `totalSupply()`, `balanceOf(address)`, `transfer`, `approve`, `allowance`, and `transferFrom`, plus the expected events.

The current contract uses a public `balances` mapping and a public `totalSupply` variable, so Solidity generates getters named `balances(address)` and `totalSupply()`. These names do not by themselves make it ERC-20-compatible.

### Things to improve or test

- Decide whether transfers to `address(0)` should be rejected.
- Consider whether the constructor should mint a fixed supply or accept a configurable supply.
- Add tests for exact-balance transfers, zero-value transfers, insufficient balances, and recipient edge cases.
- If the goal is real ERC-20 compatibility, implement the standard interface or use a well-reviewed implementation such as OpenZeppelin Contracts rather than improvising a production token.
- A public `totalSupply` variable does not automatically enforce a supply policy; the code must preserve the intended relationship between supply and balances.

**Takeaway:** a token is not magic. At its simplest, it is carefully maintained state plus rules that control how that state changes.

---

## 2. `Ticket.sol` — Limited-ticket sale
**Date in repository notes:** 18 August 2026  
**Level:** Beginner / access control and Ether payments  
**Source:** [`Ticket.sol`](https://github.com/bijan53c/Solidity/blob/main/Ticket.sol)

### The idea

Imagine an event with a limited number of tickets. The venue owner can set the available count, buyers can purchase tickets for exactly `0.01 ether`, and the owner can withdraw the Ether collected by the contract.

The source contract is named `Counter`; the ticket behavior is represented by a counter that is decremented when a purchase succeeds.

### Main concepts

- **Ownership:** the constructor stores `msg.sender` in `owner`.
- **Access control:** `onlyOwner` prevents non-owners from calling owner-only functions.
- **Modifiers:** a reusable way to check a condition before executing a function.
- **`view`:** a function that reads state but does not modify it.
- **`payable`:** allows a function to receive Ether.
- **`msg.value`:** the amount of wei sent with the call.
- **`address(this).balance`:** the Ether balance held by this contract.
- **Low-level Ether transfer:** `owner.call{value: amount}("")` attempts to send Ether and returns a success flag.

### Understanding the modifier

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not the venue");
    _;
}
```

The `require` checks that the caller is the owner. The underscore (`_;`) marks where the function body runs after the check passes.

For example, `increment()` uses `onlyOwner`, so a non-owner cannot increase the available ticket count through that function.

### Understanding the purchase logic

```solidity
require(count > 0, "Sold out");
require(msg.value == ticketPrice, "Wrong payment amount");
count -= 1;
```

The contract checks that tickets remain and that the buyer sends the exact price. If either condition fails, the transaction reverts. A revert also rolls back the state changes in that transaction.

Exact equality rejects both underpayment and overpayment. This is a deliberate design choice for the exercise.

### Withdrawal flow

The owner reads the contract's current Ether balance, calls the owner's address with that value, and checks the returned `success` flag. If the send fails, `require(success, ...)` reverts.

### Important issues to think about

- The contract has no explicit function to add tickets other than the owner-only `increment()`. A more descriptive interface might use `addTickets(uint256 amount)`.
- A production ticket system should track individual tickets or purchase records if tickets need to be verified, transferred, or refunded.
- Consider reentrancy and withdrawal patterns whenever a contract sends Ether to an external address. This example checks the call result, but it is still worth learning the checks-effects-interactions pattern and using established libraries where appropriate.
- The `count` variable is private and exposed through `getCount()`. This is fine for practice, though public state variables can generate getters automatically.
- The code does not establish that each decrement corresponds to a unique real-world attendee or ticket ID.

**Takeaway:** smart contracts need explicit rules about who can change state, what payment is valid, and what happens when a condition fails.

---

## 3. `SimpleStorage.sol` — First storage experiment
**Date in repository notes:** 5 September 2026  
**Level:** Beginner / arrays, mappings, and user input  
**Source:** [`SimpleStorage.sol`](https://github.com/bijan53c/Solidity/tree/main/SimpleStorage)

### The idea

The goal is to let users save a string under a numeric ID. This experiment explores two ways to organize data:

- An **array**, which is useful for ordered entries accessed by index.
- A **mapping**, which is useful for looking up a value by a key.

The first version is intentionally an early practice step. It is useful for seeing what happens before access-control rules are added.

### Main concepts

- **Structs:** group related values into one custom data type.
- **Dynamic arrays:** grow as entries are pushed.
- **Mappings:** associate a key with a value.
- **`public`:** generates an automatic getter for a public state variable.
- **`string memory`:** declares a temporary memory copy of a string parameter for the duration of the call.
- **State-changing functions:** writing to storage requires a transaction when called externally on a deployed contract.

### Array versus mapping

An array is like a numbered list. You can append an entry and retrieve it by its array index. A mapping is more like a dictionary: provide a key, and Solidity returns the value associated with it.

Mappings do not track a list of keys and cannot be iterated over directly. If a contract needs to enumerate every entry, it usually needs a separate array or another data structure designed for that purpose.

### What the first version teaches

It demonstrates how a function accepts a user-supplied ID and string, then stores the data. But if any caller can write to the same ID, a later call can overwrite the earlier value. That is a key transition from “I can store data” to “I have defined who owns each record.”

**Takeaway:** choosing a data structure is only half the job; define the rules for updating its contents too.

---

## 4. `SimpleStorageFaulty.sol` — First version of the storage record
**Date:** part of the SimpleStorage learning sequence recorded on 7 September 2026  
**Level:** Beginner / structs and duplicated representations  
**Source:** [`SimpleStorageFaulty.sol`](https://github.com/bijan53c/Solidity/blob/main/SimpleStorage/SimpleStorageFaulty.sol)

### The structure

```solidity
struct EntryData {
    uint256 ItemID;
    string StringData;
}

EntryData[] public DataList;
mapping(uint256 => string) public DataIdToData;
```

Each array entry stores both an ID and a string. The mapping stores a string under an ID.

### What to notice

The same conceptual information is stored in two places: the array and the mapping. That can be useful for learning, but it creates a consistency responsibility. If one representation is updated and the other is not, they may disagree.

This version also allows any caller to write to an existing ID. A user can replace another user's mapping value because the contract does not track or check ownership.

### Learning questions

- If two calls use the same ID, what does the mapping return afterward?
- Does appending to the array replace the old array entry? (No: it adds another entry.)
- Can the array and mapping tell different stories about the same ID? (Yes.)
- What rule would prevent one user from overwriting another user's record?

**Takeaway:** a contract can compile and still fail to enforce the behavior people expect.

---

## 5. `SimpleStorageBug.sol` — Adding an owner field without enforcing ownership
**Date:** part of the SimpleStorage learning sequence recorded on 7 September 2026  
**Level:** Beginner-to-intermediate / authorization logic  
**Source:** [`SimpleStorageBug.sol`](https://github.com/bijan53c/Solidity/blob/main/SimpleStorage/SimpleStorageBug.sol)

### The change

The record now stores an owner address:

```solidity
struct EntryData {
    string StringData;
    address Owner;
}
```

When an entry is written, the contract stores `msg.sender` as the owner.

### The subtle bug

Recording who wrote a value is not the same as checking who is allowed to change it. In this version, `AddData` still unconditionally assigns a new `EntryData` to the requested ID. A different caller can overwrite the record and become the new recorded owner.

This is a useful security lesson: **metadata is not access control**. An owner field has no protective effect unless the code checks it before allowing a write.

### How to reason about the fix

Before changing a record, ask:

1. Is this ID unused?
2. If it is already assigned, is the current caller the recorded owner?
3. If neither condition is true, should the transaction revert?

That reasoning leads to the guard in the next version.

**Takeaway:** authorization must be enforced at the point where a sensitive state change happens.

---

## 6. `SimpleStorageMain.sol` — Storage with an ownership check
**Date:** part of the SimpleStorage learning sequence recorded on 7 September 2026  
**Level:** Beginner-to-intermediate / mappings, structs, and `require`  
**Source:** [`SimpleStorageMain.sol`](https://github.com/bijan53c/Solidity/blob/main/SimpleStorage/SimpleStorageMain.sol)

### The improved design

```solidity
struct EntryData {
    string StringData;
    address Owner;
}

mapping(uint256 => EntryData) public DataIdToData;

function AddData(uint256 _ItemID, string memory _StringData) public {
    require(
        DataIdToData[_ItemID].Owner == msg.sender ||
        DataIdToData[_ItemID].Owner == address(0),
        "this ID is assigned to someone else!"
    );

    DataIdToData[_ItemID] = EntryData(_StringData, msg.sender);
}
```

The `require` permits a write only when either:

- The caller is already the owner of the ID, or
- The stored owner is `address(0)`, used here as the marker for an unused entry.

If neither condition is true, the transaction reverts.

### Why `address(0)` works here

A mapping returns a default value for a key that has never been written. For a struct, each member receives its type's default value. The default address is `address(0)`, so the contract uses that value to detect an unassigned record.

This is a common Solidity pattern, but it must be chosen carefully: the sentinel value should not also be a valid owner in the application's intended logic.

### What this version improves

- It records the caller as the entry owner.
- It stops other addresses from overwriting an ID that is already owned.
- It lets the same owner update their own string.
- It demonstrates a simple authorization check close to the state update it protects.

### Further improvements

- Consider renaming `Owner` to `owner` and `AddData` to `addData` to follow common Solidity naming conventions.
- Decide whether owners should be able to delete entries or transfer ownership.
- Add automated tests for first write, owner update, unauthorized update, and writes to different IDs.
- Consider whether you actually need both an array and a mapping. The current version comments out the array, which avoids maintaining two active representations.
- Do not assume the stored string is private. Public blockchain storage should be treated as visible, even if a frontend does not display it.

**Takeaway:** a secure-enough learning example evolves from storing data to defining ownership and enforcing that ownership consistently.

---

## 7. `factory.sol` — Deploying and interacting with other contracts
**Date:** not explicitly shown in the repository README  
**Level:** Intermediate / contract creation, arrays of contract instances, and interfaces  
**Source:** [`factory.sol`](https://github.com/bijan53c/Solidity/blob/main/factory.sol)

### The idea

A factory contract creates new `SimpleStorage` instances and keeps their references in an array. It then lets callers write to and read from a selected instance.

```solidity
import {SimpleStorage} from "./SimpleStorageMain.sol";

contract ContractFactory {
    SimpleStorage[] ListOfSimpleStorageContracts;

    event NewSimpleStorageMade(address _AddressString);

    function ContractBuilder() public {
        SimpleStorage NewSimpleStorage = new SimpleStorage();
        ListOfSimpleStorageContracts.push(NewSimpleStorage);
        emit NewSimpleStorageMade(address(NewSimpleStorage));
    }
}
```

The factory does not merely store data itself. It deploys other contracts and remembers their addresses through typed contract references.

### Main concepts

- **Imports:** bring a contract definition from another file into the current source file.
- **`new SimpleStorage()`:** deploys a new instance of that contract.
- **Arrays of contract types:** store references to deployed instances.
- **Events:** announce that a new instance was created and expose its address in transaction logs.
- **Cross-contract calls:** call functions on a contract instance held by the factory.
- **ABI:** the Application Binary Interface describes how callers encode function calls and decode returned data. In Solidity, importing a contract gives the compiler the information it needs to type-check these calls.

### Reading and writing through the factory

The `sfStore` function chooses a contract using `_SimpleStorageIndex`, then calls `AddData` on that instance. `SfGet` reads from the selected instance and returns the data and address as described by the source.

### Important design questions

- The index must be within the array bounds; otherwise the call reverts.
- Anyone can call `ContractBuilder`, so anyone can cause the factory to deploy another storage contract. That may be intended, but access rules should be explicit.
- In the current example, the factory is the caller of `SimpleStorage.AddData`, not the external user who called the factory. Therefore, the storage contract sees the factory as `msg.sender`. This affects the ownership check in `SimpleStorageMain.sol`: records written through the factory will be owned by the factory contract, not by the end user.
- `ContractBuilder` is a function rather than a constructor, so it can be called repeatedly. A clearer name under common style conventions would be `createSimpleStorage`.
- For a real application, consider returning the new contract address and emitting a consistently named event.

**Takeaway:** when contracts call other contracts, `msg.sender` changes at each call boundary. Always identify which address the callee actually sees.

---

## 8. `FundMe/PriceConverter.sol` — Reading a price feed
**Date:** not explicitly shown in the repository README  
**Level:** Intermediate / libraries, external interfaces, and oracle data  
**Source:** [`PriceConverter.sol`](https://github.com/bijan53c/Solidity/blob/main/FundMe/PriceConverter.sol)

### The idea

This helper library reads an ETH/USD price from a Chainlink Aggregator V3 price feed and converts an Ether amount into a USD-denominated integer representation.

### Main concepts

- **Libraries:** reusable functions that can be called by contracts.
- **Interfaces:** `AggregatorV3Interface` defines the external functions expected from a compatible price feed.
- **External contract calls:** `latestRoundData()` retrieves the latest round data.
- **Fixed-point arithmetic:** Solidity does not use floating-point numbers for ordinary contract arithmetic, so prices are represented as integers with a known decimal scale.
- **Unit conversion:** the result must account for both the price feed's decimals and Ether's 18 decimal places.

### Understanding the conversion

The code reads the signed `price`, casts it to `uint256`, and multiplies by `1e10`, with a comment indicating the resulting ETH/USD value is represented with 18 decimals. It then multiplies that price by `ethAmount` and divides by `1e18` to account for the Ether amount's scale.

This arithmetic depends on the feed having the expected decimal count. The code does not query `decimals()` dynamically, and it does not check that the returned price is positive or that the feed data is fresh. Those are important checks to consider before using an oracle value to make financial decisions.

### Network-specific warning

The feed address in the source is a specific address associated with an ETH/USD feed on Ethereum mainnet. Oracle addresses are network-specific; do not assume this address is correct on another chain or test network.

**Takeaway:** an oracle gives a smart contract access to external data, but the contract still needs to validate the value, its units, and whether it is suitable for the decision being made.

---

## 9. `test.sol` — Solidity type and data-structure scratchpad
**Date:** not explicitly shown in the repository README  
**Level:** Beginner / language fundamentals  
**Source:** [`test.sol`](https://github.com/bijan53c/Solidity/blob/main/test.sol)

This file is a scratchpad of Solidity concepts rather than a complete application. It includes examples of:

- `bool`, `uint256`, `int256`, `string`, and `bytes32`.
- A public state variable and a function that updates it.
- An `internal pure` function that returns a constant.
- A `Person` struct and an array of `Person` entries.
- A function that adds a person to the array.
- Comments about `memory`, `calldata`, and `storage`.

### The important distinctions

- **`uint256`:** an unsigned 256-bit integer; it cannot represent negative numbers.
- **`int256`:** a signed 256-bit integer; it can represent negative values.
- **`bytes32`:** a fixed-size 32-byte value. It is not the same type as dynamically sized `bytes`.
- **`public`:** creates a getter for a public state variable.
- **`internal`:** the function can be called from within the contract and derived contracts, but not directly as an external transaction entry point.
- **`pure`:** the function promises not to read or modify contract state.
- **`struct`:** groups related values into a custom record.
- **`array.push(...)`:** appends an element to a dynamic array.

### Data locations: a practical mental model

- **`storage`:** persistent contract state.
- **`memory`:** temporary data while a function executes; mutable within that execution.
- **`calldata`:** temporary call input, generally read-only. It is often a good choice for external function parameters when the type supports it.

The comment in the source that “calldata and memory are temporary” is a useful first approximation, but data locations have specific rules and are not interchangeable for every type and function.

**Takeaway:** become comfortable with types, functions, structs, arrays, and data locations before moving on to contracts that hold money or coordinate other contracts.

---

# Part II — Recommended learning order

The timeline above preserves the dates and the progression recorded in the repository. For a learner starting from the beginning, I recommend this order instead.

## Stage 1 — Learn the language building blocks
**Start with:** [`test.sol`](https://github.com/bijan53c/Solidity/blob/main/test.sol)

Learn types, variables, functions, visibility, mutability (`view` / `pure`), structs, arrays, and data locations.

**Move on when you can:**
- Explain the difference between `uint256` and `int256`.
- Write a function that changes a state variable.
- Return a value from a function.
- Create a struct and append it to an array.
- Explain where `storage`, `memory`, and `calldata` are used.

## Stage 2 — Store and retrieve user data
**Start with:** [`SimpleStorage.sol`](https://github.com/bijan53c/Solidity/tree/main/SimpleStorage)

Practice mappings, arrays, structs, and custom IDs. Understand the difference between an array index and a mapping key.

**Move on when you can:**
- Store a string under a numeric ID.
- Explain what happens when an ID is written twice.
- Explain why mappings do not provide a list of their keys.

## Stage 3 — Add ownership and authorization
**Read in order:**
1. [`SimpleStorageFaulty.sol`](https://github.com/bijan53c/Solidity/blob/main/SimpleStorage/SimpleStorageFaulty.sol)
2. [`SimpleStorageBug.sol`](https://github.com/bijan53c/Solidity/blob/main/SimpleStorage/SimpleStorageBug.sol)
3. [`SimpleStorageMain.sol`](https://github.com/bijan53c/Solidity/blob/main/SimpleStorage/SimpleStorageMain.sol)

The faulty and buggy versions are valuable because they show why recording an owner is not enough. The final version checks ownership before allowing a record to be changed.

**Move on when you can:**
- Describe the overwrite flaw in the early versions.
- Explain the role of `msg.sender`.
- Explain why `address(0)` can represent an unused mapping entry.
- Write tests for authorized and unauthorized updates.

## Stage 4 — Build a payable contract with access control
**Start with:** [`Ticket.sol`](https://github.com/bijan53c/Solidity/blob/main/Ticket.sol)

Learn modifiers, ownership, `payable`, `msg.value`, `require`, contract balances, and withdrawals.

**Move on when you can:**
- Explain why the ticket purchase checks both availability and exact payment.
- Explain what happens to a transaction when a `require` fails.
- Explain why Ether transfers need careful failure handling.
- Test owner and non-owner calls.

## Stage 5 — Model balances and token transfers
**Start with:** [`CFC.sol`](https://github.com/bijan53c/Solidity/blob/main/CFC.sol)

Learn balance mappings, constructors, transfer accounting, and events. Then compare your implementation with the ERC-20 standard.

**Move on when you can:**
- Explain how a transfer updates two balances.
- Explain why events matter to off-chain applications.
- Identify which ERC-20 features are missing from the practice contract.
- Test insufficient balance and edge cases.

## Stage 6 — Compose contracts
**Start with:** [`factory.sol`](https://github.com/bijan53c/Solidity/blob/main/factory.sol)

Learn imports, deployment with `new`, storing contract references, events, and cross-contract calls. Pay special attention to `msg.sender` when one contract calls another.

**Move on when you can:**
- Deploy more than one child contract from a factory.
- Retrieve a child contract's address.
- Explain which address the child contract sees as `msg.sender`.
- Handle invalid array indexes and decide who can create instances.

## Stage 7 — Use external data carefully
**Start with:** [`PriceConverter.sol`](https://github.com/bijan53c/Solidity/blob/main/FundMe/PriceConverter.sol)

Learn interfaces, libraries, Chainlink price feeds, integer precision, and unit conversion. Then study feed decimals, stale data, negative/invalid values, network-specific addresses, and failure behavior.

**Move on when you can:**
- Explain how an interface enables a call to another contract.
- Calculate the decimal scaling used by a price feed.
- Validate that a returned price is positive and sufficiently recent.
- Confirm the correct feed address and decimals for the target network.

---

# Part III — Security and quality checklist

Before treating any practice contract as more than a learning exercise, review these questions.

## Access control
- Who can call each state-changing function?
- Is an owner recorded, and is that owner actually checked?
- Does a contract-to-contract call change the value of `msg.sender` in a way that affects permissions?

## State consistency
- Is the same data stored in multiple places?
- Can those copies become inconsistent?
- Are IDs unique, reusable, or owned by a particular address?

## Ether and token transfers
- Can a user spend more than their balance?
- Are zero addresses handled intentionally?
- Can Ether transfers fail, and is the result checked?
- Have you considered reentrancy and checks-effects-interactions?

## External data
- Is the oracle address correct for the current network?
- Are the price's decimals and units understood?
- Are negative, zero, stale, or otherwise invalid answers handled?

## Testing
At minimum, test the expected path, invalid inputs, unauthorized callers, boundary values, and failure cases. A contract compiling successfully does not prove that its business rules or security properties are correct.

---

# Part IV — Suggested exercises

1. **SimpleStorage:** add a function that returns the owner of a record, and test it with two accounts.
2. **SimpleStorage:** decide whether an owner can delete or transfer a record. Write down the intended rule before coding it.
3. **Ticket:** replace the one-at-a-time counter increment with an owner-only `addTickets(uint256 amount)` function.
4. **Ticket:** write tests for underpayment, overpayment, sold-out purchases, and non-owner withdrawal.
5. **CFC:** reject transfers to the zero address and test exact-balance and insufficient-balance transfers.
6. **CFC:** compare the current implementation with ERC-20 and list every missing function or behavior before implementing them.
7. **Factory:** return the deployed child address and test writing to two separate child contracts.
8. **PriceConverter:** use the feed's `decimals()` method rather than assuming a fixed decimal count, and validate the answer before using it.
9. **Every contract:** write tests that demonstrate at least one bug or invalid state transition, then show that the fix prevents it.

---

# Closing note

These notes are intended to make the reasoning behind each exercise easier to follow—not to replace the Solidity documentation, testing, or a security review. The most useful part of a learning repository is often the path from the first attempt to the corrected version. Keep the mistakes, explain what they taught you, and show how the next version improves the design.

For reference, see the [official Solidity documentation](https://docs.soliditylang.org/) and the [OpenZeppelin Contracts documentation](https://docs.openzeppelin.com/contracts/).
