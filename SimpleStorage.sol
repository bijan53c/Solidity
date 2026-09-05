// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract SimpleStorage {

    //Structure to save user entry data by contract to blockchain 
    struct EntryData {
        uint256 ItemID;
        string StringData;
    }

    //The list/array to save the entered data into
    // Letting user to read data by entry index
    EntryData [] public DataList;


    // Mapping : letting user to gather data by the entered custom ID
    mapping (uint256 => string) public DataIdToData;


    //Add data by array and mapping
    function AddData(uint256 _ItemID, string memory _StringData) public {
        DataList.push (EntryData(_ItemID,_StringData));
        DataIdToData[_ItemID] = _StringData;
    }
}
