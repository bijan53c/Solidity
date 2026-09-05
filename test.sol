// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract learn{

    //types bool uint , int, byte ,address

    // a boolean variable set true
    bool hasNum = true;

    // an integer variable with a data
    // using uint/int we can specify the bits of number can be used in variable
    //using "uint" by default sets uint256
    uint256 public NUM = 512;
    //leaving it empty by default goes 0

    //int can contain negative value
    int256 otherNum = -512;


    // you can use "string" for putting string in variables
    string STRVAR = "HAHAHA HOHO HO";

    //For putting address as a variable and use, you gotta put uknow
    //valid address in it

    //address adddress = "ADRESS STRING"

    //bytes are same as text under the hood
    // text can get converted to bytes
    // type bytes32 != bytes, unlike uint and uint256
    bytes32 FavBytes = "DOG";


    //functions
    //Using it for updating the num
    function store (uint256 _newNUM) public {
        NUM = _newNUM;
    }

    function get() internal pure returns(uint256){
        return 7;
    }

    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    Person[] public listOfPeople;
    //calldata, memory, storage
    //calldata and memory are temporary varialbes but calldata can't be modified and memory can
    // storage is permanent variable
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        //Person newPerson = Person (_faviriteNumber, _name)
        listOfPeople.push(Person(_favoriteNumber, _name));
    }

}
