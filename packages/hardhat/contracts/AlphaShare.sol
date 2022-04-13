// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

///@title A File sharing and storage PoC for a Decentralized Library
///@author AlphaShare Team
///@notice You can use this contract for the most basic decentralized file sharing operation.
///@dev contract under development to enable users to upload files, retrieve files and share files with other users.
contract AlphaShare {
<<<<<<< HEAD
    using EnumerableSet for EnumerableSet.AddressSet;
=======

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet; 
>>>>>>> 9cc9e7def2184e144da81066d035f52628a708a5

    mapping(uint256 => File) files;

    mapping(uint256 => Folder) folders;
    // mapping of file id to ipfs hash value
   // mapping (uint256 => string) private filsHashes;

    mapping (address => EnumerableSet.UintSet) ownedFiles;
    mapping (address => EnumerableSet.UintSet) sharedFiles;

    event StopFileShare(string fileName, address owner, address sharee);

    struct Folder {
        string Name;
        address owner;
        uint256 Id;
    }

    struct File {
        uint256 Id;
        string Name;
        string ipfsHash;
        address Owner;
        uint256 FolderId;
        uint256 Size;
        bool Visibility;
        EnumerableSet.AddressSet shared; // just to keep track of number with access
        string CreatedAt;
    }

<<<<<<< HEAD
    function stopShare(uint256 fileId, address[] memory addresses) public {
=======
    modifier fileOwner(uint fileId) {
        require(msg.sender == files[fileId].Owner, "You are not the file owner");
        _;

    }

    modifier hasAccess(uint fileId) {
        require(msg.sender == files[fileId].Owner || files[fileId].shared.contains(msg.sender) || files[fileId].Visibility, "You dont have access to this file");
        _;
    }

    function stopShare(uint fileId, address[] memory addresses) public fileOwner(fileId) {
>>>>>>> 9cc9e7def2184e144da81066d035f52628a708a5
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.shared.remove(addresses[i]);
            sharedFiles[msg.sender].remove(fileId);
            emit StopFileShare(file.Name, file.Owner, addresses[i]);
        }
    }

<<<<<<< HEAD
    function updateFileAccess() public {}
=======
    function updateFileAccess(uint fileId, bool visible) public fileOwner(fileId) {
        files[fileId].Visibility = visible;
    }

    function retreiveFile(uint fileId) public view hasAccess(fileId) returns(bytes memory) {
        File storage file = files[fileId];
        return fileToJson(file);
    }
    

    function retreiveFiles(address user) public view returns(bytes[] memory) {
        bytes[] memory  data;
        uint[] memory owned = ownedFiles[user].values();
        uint[] memory shared = sharedFiles[user].values();

        for (uint256 i = 0; i < owned.length; i++) {
            bytes memory file = fileToJson(files[owned[i]]);
            
            data[i] = file;
        }
        for (uint256 i = data.length; i < shared.length + data.length; i++) {
            bytes memory file = fileToJson(files[owned[i]]);
            data[i] = file;
        }
        return data;
    }


    function fileToJson(File storage file ) internal view returns(bytes memory){
        bytes memory json =abi.encodePacked(
               "{",
               "Id:", file.Id,
               ", Name:", file.Name,
               ", Owner:", file.Owner,
               ", ipfsHash:", file.ipfsHash,
               ", FolderId:", file.FolderId,
               ", Size:", file.Size,
               ", Visibility:", file.Visibility,
               ", Createdat:", file.CreatedAt,
               "}"
            );
        return json;
    }
>>>>>>> 9cc9e7def2184e144da81066d035f52628a708a5
}
