// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "hardhat/console.sol";

///@title A File sharing and storage PoC for a Decentralized Library
///@author AlphaShare Team
///@notice You can use this contract for the most basic decentralized file sharing operation.
///@dev contract under development to enable users to upload files, retrieve files and share files with other users.
contract AlphaShare {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => File) files;

    uint256 fileCounter = 1;

    mapping(address => EnumerableSet.UintSet) ownedFiles;
    mapping(address => EnumerableSet.UintSet) sharedWithMe;
    mapping(address => EnumerableSet.UintSet) sharedByMe;


    struct File {
        string key;
        string ipfsHash;
        address owner;
        uint256 size;
        bool visibility;
        EnumerableSet.AddressSet sharedWith;
        bool isFolder;
        uint256 createdAt;
    }

    modifier fileOwner(uint256 fileId) {
        require(
            msg.sender == files[fileId].owner,
            "You are not the file owner"
        );
        _;
    }

    modifier hasAccess(uint256 fileId) {
        require(
            msg.sender == files[fileId].owner || files[fileId].visibility || files[fileId].sharedWith.contains(msg.sender),
            "You dont have access to this file"
        );
        _;
    }

    event StartFileShare(string fileName, address owner, address sharee);
    event StopFileShare(string fileName, address owner, address sharee);

    function startFileShare(uint256 fileId, address[] memory addresses)
        public
        fileOwner(fileId)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.sharedWith.add(addresses[i]);
            emit StartFileShare(file.key, file.owner, addresses[i]);
        }
    }

    function addFile(
        string calldata key,
        string calldata ipfsHash,
        uint256 size
    ) public {
        File storage file = files[fileCounter];
        file.key = key;
        file.ipfsHash = ipfsHash;
        file.owner = msg.sender;
        file.size = size;
        file.visibility = true;
        file.createdAt = block.timestamp;
        file.isFolder = false;

        ownedFiles[msg.sender].add(fileCounter);
        fileCounter++;
    }

    function addFolder(
        string calldata key
    ) public {
        File storage file = files[fileCounter];
        file.key = key;
        file.owner = msg.sender;
        file.visibility = true;
        file.isFolder = true;

        ownedFiles[msg.sender].add(fileCounter);
        fileCounter++;
    }
    function stopShare(uint256 fileId, address[] calldata addresses)
        public
        fileOwner(fileId)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.sharedWith.remove(addresses[i]);
            sharedWithMe[addresses[i]].remove(fileId);
            sharedByMe[addresses[i]].remove(fileId);
            emit StopFileShare(file.key, file.owner, addresses[i]);
        }
    }

    function updateFileAccess(uint256 fileId, bool visibility)
        public
        fileOwner(fileId)
    {
        files[fileId].visibility = visibility;
    }

    // function retreiveFile(uint256 fileId)
    //     public
    //     view
    //     hasAccess(fileId)
    //     returns (string memory)
    // {
    //     return fileToJson(files[fileId]);
    // }

    function retreiveOwnedFiles()
        public
        view
        returns (string[] memory, string[] memory, uint[] memory, uint[] memory)
    {
        return retrieveFiles(ownedFiles[msg.sender].values());
    }

    function retreiveFilesSharedWithMe()
        public
        view
        returns (string[] memory, string[] memory, uint[] memory, uint[] memory)
    {
        return retrieveFiles(sharedWithMe[msg.sender].values());
    }

    function retrieveFilesSharedByMe()
        public
        view
        returns (string[] memory, string[] memory, uint[] memory, uint[] memory)
    {
        return retrieveFiles(sharedByMe[msg.sender].values());
    }

    function retrieveFiles(uint[] memory fileIds)
        internal
        view
        returns (string[] memory, string[] memory, uint[] memory, uint[] memory)
    {
        string[]  memory key = new string[](fileIds.length);
        string[]  memory ipfsHash = new string[](fileIds.length);
        uint[]  memory size = new uint[](fileIds.length);
        uint[]  memory createdAt = new uint[](fileIds.length);

        for (uint256 i = 0; i < fileIds.length; i++) {
            File storage file = files[fileIds[i]];
            key[i] = file.key;
            ipfsHash[i] = file.ipfsHash;
            size[i] = file.size;
            createdAt[i] = file.createdAt;

        }

        return (key, ipfsHash, size, createdAt);
    }
}
