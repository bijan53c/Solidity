//SPDX-License-Identifier: MIT
pragma solidity ^ 0.6.0;

contract SafeMathTester{
    uint8 public bigNumber = 255;

    function add() public {
        bigNumber = bigNumber + 1;
    }
}

//varaible overflow cause of solidity version
// :: Try adding to the big number and see what happens

// from 0.8.0 The issue got solved and no need to use SafeMath on the contracts for overflows or variable checks
