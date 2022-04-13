// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AlphaShare
 * @dev Upload files and store ipfs hash values, track the stored values for every address who calls the contract
 */

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AlphaShare {

    using EnumerableSet for EnumerableSet.AddressSet;
    using Counters for Counters.Counter;
    Counters.Counter _fileIds;

    mapping(uint256 => File) files;
    mapping(uint256 => Folder) folders;
       // use to link an address with the stored files
    mapping(address => mapping(uint256 => UserFile)) public UserFiles;
    // use to check if an address already store some files
    mapping(address => bool) public isSet;
    // use the address to track the number of uploaded files
    mapping(address => uint256) public totalID;

    event StopFileShare(string fileName, address owner, address sharee);

   
    struct UserFile {
        string ipsHash;
        //string description;
    }

    struct File {
        string ipfsHash;
        string Name;
        address owner;
        uint256 FolderId;
        uint256 size;
        bool visibility;
        EnumerableSet.AddressSet shared;
        string createdAt;
    }

    function stopShare(uint fileId, address[] memory addresses) public {
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.shared.remove(addresses[i]);
            emit StopFileShare(file.Name, file.owner, addresses[i]);
        }
    }

    function updateFileAccess() public{

    }


    // Uploading file

     struct Folder {
        string Name;
        address owner;
        uint256 Id;
    }


    function setUser(address _add) internal {
        isSet[_add] = true;
        totalID[_add] = 0;
    }

    function updateUser(address _add, uint256 _key) internal {
        totalID[_add] = _key;
    }

    function getTotalUserID(address _add) internal view returns (uint256) {
        return totalID[_add];
    }

    function getTotal(address _add) external view returns (uint256) {
        require(isSet[_add], "NO Files for this address");
        return (getTotalUserID(_add) - 1);
    }

    function getAll() external view returns (UserFile[] memory) {
        require(isSet[msg.sender], "NO Files for this address");
        uint256 size = getTotalUserID(msg.sender);
        UserFile[] memory allFiles = new UserFile[](size);
        for (uint256 i = 0; i < size; i++) {
            allFiles[i] = UserFiles[msg.sender][i];
        }
        return allFiles;
    }

    function store(string memory _ipsHash) external {
        if (isSet[msg.sender]) {
            uint256 key = getTotalUserID(msg.sender);
            UserFiles[msg.sender][key] = UserFile(_ipsHash);
            updateUser(msg.sender, key + 1);
        } else {
            setUser(msg.sender);
            UserFiles[msg.sender][0] = UserFile(_ipsHash);
            updateUser(msg.sender, 1);
        }
    }

    
    
}
