// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract AlphaShare {

    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => File) files;
    mapping(uint256 => Folder) folders;

    event StopFileShare(string fileName, address owner, address sharee);

    struct Folder {
        string Name;
        address owner;
        uint256 Id;
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


}
