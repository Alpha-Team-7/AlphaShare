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

    mapping(uint256 => Folder) folders;
    // mapping of file id to ipfs hash value
   // mapping (uint256 => string) private filsHashes;

   // use to link an address with the stored files
    mapping(address => mapping(uint256 => UserFile)) public UserFiles;
    // use to check if an address already store some files
    mapping(address => bool) public isSet;
    // use the address to track the number of uploaded files
    mapping(address => uint256) public totalID;

    mapping (address => EnumerableSet.UintSet) ownedFiles;
    mapping (address => EnumerableSet.UintSet) sharedFiles;


    // Uploading file

    struct UserFile {
        string ipsHash;
        //string description;
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

    modifier fileOwner(uint fileId) {
        require(msg.sender == files[fileId].Owner, "You are not the file owner");
        _;

    }

    modifier hasAccess(uint fileId) {
        require(msg.sender == files[fileId].Owner || files[fileId].shared.contains(msg.sender) || files[fileId].Visibility, "You dont have access to this file");
        _;
    }

    event StartFileShare(string fileName, address owner, address sharee);

    function startFileShare(uint fileId, address[] memory addresses) public fileOwner(fileId) {
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.shared.add(addresses[i]);
            sharedFiles[msg.sender].add(fileId);
            emit StartFileShare(file.Name, file.Owner, addresses[i]);
        }
    }

    event StopFileShare(string fileName, address owner, address sharee);

    function stopShare(uint fileId, address[] memory addresses) public fileOwner(fileId) {
        for (uint256 i = 0; i < addresses.length; i++) {
            File storage file = files[fileId];
            file.shared.remove(addresses[i]);
            sharedFiles[msg.sender].remove(fileId);
            emit StopFileShare(file.Name, file.Owner, addresses[i]);
        }
    }

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

}
