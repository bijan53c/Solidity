//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.18 ;

import {SimpleStorage} from "./SimpleStorageMain.sol" ;

contract ContractFactory {

    SimpleStorage[] ListOfSimpleStorageContracts;


    
    function ContractBuilder() public {
        SimpleStorage NewSimpleStorage = new SimpleStorage();
        ListOfSimpleStorageContracts.push(NewSimpleStorage);
    }
    //Writes to deployed new contract
    function sfStore(uint256 _SimpleStorageIndex,  string memory _DATA, uint256 _ID) public {
        //Address
        //ABI Application binary interface 
        ListOfSimpleStorageContracts[_SimpleStorageIndex].AddData(_ID,_DATA);
    }

    //reads from deployed contract
    //function SfGet (uint256 _ssindex, uint256 _SimpleStorageDataID) public view returns(string memory) {
    //    return ListOfSimpleStorageContracts[_ssindex].DataIdToData(_SimpleStorageDataID);
    //}
}
