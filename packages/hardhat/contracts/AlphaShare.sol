// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

///@title A File sharing and storage PoC for a Decentralized Library
///@author AlphaShare Team
///@notice You can use this contract for the most basic decentralized file sharing operation.
///@dev contract under development to enable users to upload files, retrieve files and share files with other users.
contract AlphaShare {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => File) files;

    uint256 fileCounter = 1;

    // mapping(uint256 => Folder) folders;
    // mapping of file id to ipfs hash value
    // mapping (uint256 => string) private filsHashes;

    mapping(address => EnumerableSet.UintSet) ownedFiles;
    mapping(address => EnumerableSet.UintSet) sharedWithMe;

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
            emit StopFileShare(file.key, file.owner, addresses[i]);
        }
    }

    function updateFileAccess(uint256 fileId, bool visibility)
        public
        fileOwner(fileId)
    {
        files[fileId].visibility = visibility;
    }

    function retreiveFile(uint256 fileId)
        public
        view
        hasAccess(fileId)
        returns (bytes memory)
    {
        File storage file = files[fileId];
        return fileToJson(file);
    }

    function retreiveOwnedFiles()
        public
        view
        returns (bytes[] memory)
    {
        bytes[] memory data;
        uint256[] memory owned = ownedFiles[msg.sender].values();

        for (uint256 i = 0; i < owned.length; i++) {
            bytes memory file = fileToJson(files[owned[i]]);

            data[i] = file;
        }

        return data;
    }

    function retreiveFilesSharedWithMe()
        public
        view
        returns (bytes[] memory)
    {
        bytes[] memory data;
        uint256[] memory shared = sharedWithMe[msg.sender].values();

        for (uint256 i = 0; i < shared.length; i++) {
            bytes memory file = fileToJson(files[shared[i]]);
            data[i] = file;
        }
        return data;
    }

    function fileToJson(File storage file)
        internal
        view
        returns (bytes memory)
    {
        bytes memory json = abi.encodePacked(
            "{",
            "key:",
            file.key,
            ", owner:",
            file.owner,
            ", ipfsHash:",
            file.ipfsHash,
            ", size:",
            file.size,
            ", visibility:",
            file.visibility,
            ", createdAt:",
            file.createdAt,
            "}"
        );
        return json;
    }
}
