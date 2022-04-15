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
    mapping(address => EnumerableSet.UintSet) ownedFiles;
    mapping(address => EnumerableSet.UintSet) sharedWithMe;
    mapping(address => EnumerableSet.UintSet) sharedByMe;
    EnumerableSet.UintSet publicFiles;
    uint256 public fileCounter = 1;

    struct File {
        uint id;
        string key;
        string ipfsHash;
        address owner;
        uint256 size;
        bool visibility;
        EnumerableSet.AddressSet sharedWith;
        bool isFolder;
        uint256 createdAt;
    }

    /** MODIFIERS */
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

    /** EVENTS */
    event AddFile(uint id, string key, string ipfsHash, uint size, uint createdAt, bool visibility, address owner);
    event StartFileShare(uint id, address owner, address sharee);
    event StopFileShare(uint id, address owner, address sharee);
    event UpdateVisibility(uint id, bool visibility);

    function addFiles(
        string[] calldata key,
        string[] calldata ipfsHash,
        uint256[] calldata size,
        bool visibility
    ) public {
        for(uint i = 0; i < key.length; i++){
            addFile(key[i], ipfsHash[i], size[i], visibility);
        }
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

    function startFileShares(uint256[] calldata fileIds, address[] memory addresses)
        public
    {
        for (uint256 i = 0; i < fileIds.length; i++) {
            startFileShare(fileIds[i], addresses);
        }
    }

    function stopShare(uint256 fileId, address[] calldata addresses)
        public
        fileOwner(fileId)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.sharedWith.remove(addresses[i]);
            sharedWithMe[addresses[i]].remove(fileId);
            sharedByMe[msg.sender].remove(fileId);
            emit StopFileShare(file.id, file.owner, addresses[i]);
        }
    }

    function updateFilesAccess(uint256[] calldata fileIds, bool visibility)
        public
    {
        for (uint256 i = 0; i < fileIds.length; i++) {
            updateFilesAccess(fileIds[i], visibility);
        }
    }

    function retreiveOwnedFiles()
        public
        view
        returns (uint[] memory, string[] memory, string[] memory, uint[] memory, uint[] memory, bool[] memory)
    {
        return retrieveFiles(ownedFiles[msg.sender].values());
    }

    function retreiveFilesSharedWithMe()
        public
        view
        returns (uint[] memory, string[] memory, string[] memory, uint[] memory, uint[] memory, bool[] memory)
    {
        return retrieveFiles(sharedWithMe[msg.sender].values());
    }

    function retrieveFilesSharedByMe()
        public
        view
        returns (uint[] memory, string[] memory, string[] memory, uint[] memory, uint[] memory, bool[] memory)
    {
        return retrieveFiles(sharedByMe[msg.sender].values());
    }

    function retrievePublicFiles()
        public
        view
        returns (uint[] memory, string[] memory, string[] memory, uint[] memory, uint[] memory, bool[] memory)
    {
        return retrieveFiles(publicFiles.values());
    }

    function retrieveAddressSharedWith (uint fileId) public view
        fileOwner(fileId) returns (address[] memory)
    {
        return files[fileId].sharedWith.values();
    }



    /** INTERNAL FUNCTIONS... */

    function addFile(
        string calldata key,
        string calldata ipfsHash,
        uint256 size,
        bool visibility
    ) internal {
<<<<<<< HEAD
        File storage file = files[fileCounter];
=======
        File storage file = files[fileCounter]; 
>>>>>>> 01e46dacad130137bf4c056dc952b2ea9b05e43b
        
        file.id = fileCounter;
        file.key = key;
        file.ipfsHash = ipfsHash;
        file.owner = msg.sender;
        file.size = size;
        file.visibility = visibility;
        file.createdAt = block.timestamp;
        file.isFolder = false;

        ownedFiles[msg.sender].add(fileCounter);

        // Update Public Files
        addRemovePublic(fileCounter, visibility);

        fileCounter++;

        emit AddFile(file.id, key, ipfsHash, size, block.timestamp, visibility, msg.sender);
    }

    function startFileShare(uint256 fileId, address[] memory addresses)
        internal
        fileOwner(fileId)
    {
        for (uint256 j = 0; j < addresses.length; j++) {
            File storage file = files[fileId];
            file.sharedWith.add(addresses[j]);
            sharedWithMe[addresses[j]].add(fileId);
            sharedByMe[msg.sender].add(fileId);
            emit StartFileShare(file.id, file.owner, addresses[j]);
        }
    }

    function addRemovePublic(uint fileId, bool visibility) internal {
        // Add or remove from public
        if(visibility){
            publicFiles.add((fileId));
        }else{
            publicFiles.remove(fileId);
        }

        emit UpdateVisibility(fileId, visibility);
    }

    function updateFilesAccess(uint256 fileId, bool visibility)
        internal
        fileOwner(fileId)
    {
        files[fileId].visibility = visibility;
        addRemovePublic(fileId, visibility);
    }

    function retrieveFiles(uint[] memory fileIds)
        internal
        view
        returns (uint[] memory, string[] memory, string[] memory, uint[] memory, uint[] memory, bool[] memory)
    {
        uint[]  memory id = new uint[](fileIds.length);
        string[]  memory key = new string[](fileIds.length);
        string[]  memory ipfsHash = new string[](fileIds.length);
        uint[]  memory size = new uint[](fileIds.length);
        uint[]  memory createdAt = new uint[](fileIds.length);
        bool[]  memory visibility = new bool[](fileIds.length);

        for (uint256 i = 0; i < fileIds.length; i++) {
            uint fileId = fileIds[i];
            File storage file = files[fileId];
            id[i] = file.id;
            key[i] = file.key;
            ipfsHash[i] = file.ipfsHash;
            size[i] = file.size;
            createdAt[i] = file.createdAt;
            visibility[i] = file.visibility;
        }

        return (id, key, ipfsHash, size, createdAt, visibility);
    }
}