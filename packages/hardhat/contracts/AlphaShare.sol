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
        uint256 id;
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
            msg.sender == files[fileId].owner ||
                files[fileId].visibility ||
                files[fileId].sharedWith.contains(msg.sender),
            "You dont have access to this file"
        );
        _;
    }

    /** EVENTS */
    event AddFile(
        uint256 id,
        string key,
        string ipfsHash,
        uint256 size,
        uint256 createdAt,
        bool visibility,
        address owner
    );

    ///@param id The id of each file
    ///@param owner The owner address of the file shared
    ///@param sharee The address of user the file is shared with
    event StartFileShare(uint256 id, address owner, address sharee);
    event StopFileShare(uint256 id, address owner, address sharee);
    event UpdateVisibility(uint256 id, bool visibility);

    ///@notice function to add file
    ///@dev stores the public variables key, ipfsHash and size
    ///@param key the key of each file relating to the frontend
    ///@param ipfsHash the unique hash used to reference each file
    ///@param size the size of individual files
    ///@param visibility grants or revokes access to files
    function addFiles(
        string[] calldata key,
        string[] calldata ipfsHash,
        uint256[] calldata size,
        bool visibility
    ) public {
        for (uint256 i = 0; i < key.length; i++) {
            addFile(key[i], ipfsHash[i], size[i], visibility);
        }
    }

    ///@dev incrementing fileCounter to add folders
    ///@notice function to add folders
    function addFolder(string calldata key) public {
        File storage file = files[fileCounter];

        file.key = key;
        file.owner = msg.sender;
        file.visibility = true;
        file.isFolder = true;

        ownedFiles[msg.sender].add(fileCounter);
        fileCounter++;
    }

    ///@notice function to enable address owner to share files
    ///@dev stores the fileIds and addresses
    ///@param fileIds the id used to keep track of each file
    ///@param addresses user address for file sharing
    function startFileShares(
        uint256[] calldata fileIds,
        address[] memory addresses
    ) public {
        for (uint256 i = 0; i < fileIds.length; i++) {
            startFileShare(fileIds[i], addresses);
        }
    }

    ///@dev removes fileId and address to prevent file share
    ///@notice function to stop file sharing, called by file owner
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

    ///@dev takes in fileIds and visibility parameters to update file access
    function updateFilesAccess(uint256[] calldata fileIds, bool visibility)
        public
    {
        for (uint256 i = 0; i < fileIds.length; i++) {
            updateFilesAccess(fileIds[i], visibility);
        }
    }

    ///@dev uses msg.sender values to retrieve all address owner files
    ///@return retreiveOwnedFiles The files that belong to the address owner
    function retreiveOwnedFiles()
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        return retrieveFiles(ownedFiles[msg.sender].values());
    }

    ///@dev uses msg.sender values to retrieve the files address owner was given access to by others
    ///@return retreiveFilesSharedWithMe The files shared with the address owner
    function retreiveFilesSharedWithMe()
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        return retrieveFiles(sharedWithMe[msg.sender].values());
    }

    ///@dev uses msg.sender values to retrieve the file address owner gave others access to
    ///@return retrieveFilesSharedByMe The files shared by the address owner
    function retrieveFilesSharedByMe()
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        return retrieveFiles(sharedByMe[msg.sender].values());
    }

    ///@dev retrieveFilesSharedByMe, retreiveOwnedFiles, retrieveFilesSharedWithMe functions make use of the retrieveFiles function
    function retrievePublicFiles()
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        return retrieveFiles(publicFiles.values());
    }

    function retrieveAddressSharedWith(uint256 fileId)
        public
        view
        fileOwner(fileId)
        returns (address[] memory)
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
        File storage file = files[fileCounter];

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

        emit AddFile(
            file.id,
            key,
            ipfsHash,
            size,
            block.timestamp,
            visibility,
            msg.sender
        );
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

    ///@notice function to change visibility of files
    ///@dev changes visibility based on current state
    function addRemovePublic(uint256 fileId, bool visibility) internal {
        // Add or remove from public
        if (visibility) {
            publicFiles.add((fileId));
        } else {
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

    function retrieveFiles(uint256[] memory fileIds)
        internal
        view
        returns (
            uint256[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        uint256[] memory id = new uint256[](fileIds.length);
        string[] memory key = new string[](fileIds.length);
        string[] memory ipfsHash = new string[](fileIds.length);
        uint256[] memory size = new uint256[](fileIds.length);
        uint256[] memory createdAt = new uint256[](fileIds.length);
        bool[] memory visibility = new bool[](fileIds.length);

        for (uint256 i = 0; i < fileIds.length; i++) {
            uint256 fileId = fileIds[i];
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
