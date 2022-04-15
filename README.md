# AlphaShare

A Decentralized Library, that allows users to upload files, retrieve files and share files with other users.

> everything you need to know about AlphaShare Decentralized file storage! 🚀

Live Demo
Check out the live demo here:

# 🏄‍♂️ Quick Start

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone/fork AlphaShare:

```bash
git clone https://github.com/Alpha-Team-7/AlphaShare.git
```

> install and start your 👷‍ Hardhat chain:

```bash
cd AlphaShare
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd AlphaShare
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
cd AlphaShare
yarn deploy
```

🔏 Edit your smart contract `AlphaShare.sol` in `packages/hardhat/contracts`

📝 Edit your frontend `App.jsx` in `packages/react-app/src`

💼 Edit your deployment scripts in `packages/hardhat/deploy`

📱 Open http://localhost:3000 to see the app

# 📚 Documentation

This documentation is segmented into developer-focused messages and end-user-facing messages. These messages may be shown to the end user (the human) at the time that they will interact with the contract (i.e. sign a transaction).

@title - Title that describes the contract
@author - Name of the author
@notice - Explains to an end user what a function does
@dev - Explains to a developer any extra details
@param - Documents a single parameter from functions and events
@return - Documents one or all return variable(s) from a function

User Documentation
{
"events": {
"AddFile(uint256,string,string,uint256,uint256,bool,address)": {
"notice": "EVENTS "
}
},
"kind": "user",
"methods": {
"addFiles(string[],string[],uint256[],bool)": {
"notice": "function to add file"
},
"addFolder(string)": {
"notice": "function to add folders"
},
"startFileShares(uint256[],address[])": {
"notice": "function to enable address owner to share files"
},
"stopShare(uint256,address[])": {
"notice": "function to stop file sharing, called by file owner"
}
},
"notice": "You can use this contract for the most basic decentralized file sharing operation.",
"version": 1
}

Developer Documentation
{
"author": "AlphaShare Team",
"details": "contract under development to enable users to upload files, retrieve files and share files with other users.",
"events": {
"StartFileShare(uint256,address,address)": {
"params": {
"id": "The id of each file",
"owner": "The owner address of the file shared",
"sharee": "The address of user the file is shared with"
}
}
},
"kind": "dev",
"methods": {
"addFiles(string[],string[],uint256[],bool)": {
"details": "stores the public variables key, ipfsHash and size",
"params": {
"ipfsHash": "the unique hash used to reference each file",
"key": "the key of each file relating to the frontend",
"size": "the size of individual files",
"visibility": "grants or revokes access to files"
}
},
"addFolder(string)": {
"details": "incrementing fileCounter to add folders"
},
"retreiveFilesSharedWithMe()": {
"details": "uses msg.sender values to retrieve the files address owner was given access to by others",
"returns": {
"\_0": "retreiveFilesSharedWithMe The files shared with the address owner"
}
},
"retreiveOwnedFiles()": {
"details": "uses msg.sender values to retrieve all address owner files",
"returns": {
"\_0": "retreiveOwnedFiles The files that belong to the address owner"
}
},
"retrieveFilesSharedByMe()": {
"details": "uses msg.sender values to retrieve the file address owner gave others access to",
"returns": {
"\_0": "retrieveFilesSharedByMe The files shared by the address owner"
}
},
"retrievePublicFiles()": {
"details": "retrieveFilesSharedByMe, retreiveOwnedFiles, retrieveFilesSharedWithMe functions make use of the retrieveFiles function"
},
"startFileShares(uint256[],address[])": {
"details": "stores the fileIds and addresses",
"params": {
"addresses": "user address for file sharing",
"fileIds": "the id used to keep track of each file"
}
},
"stopShare(uint256,address[])": {
"details": "removes fileId and address to prevent file share"
},
"updateFilesAccess(uint256[],bool)": {
"details": "takes in fileIds and visibility parameters to update file access"
}
},
"title": "A File sharing and storage PoC for a Decentralized Library",
"version": 1
}

# 🔭 Learning Solidity

📕 Read the docs: https://docs.soliditylang.org

📧 Learn the [Solidity globals and units](https://docs.soliditylang.org/en/latest/units-and-global-variables.html)
