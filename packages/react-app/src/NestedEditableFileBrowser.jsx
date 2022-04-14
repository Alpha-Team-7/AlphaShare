import React, { useEffect, useState } from "react";
import Moment from "moment";

import FileBrowser, { Icons } from "react-keyed-file-browser";
import { Button } from "antd";
const { ethers } = require("ethers");

export const NestedEditableFileBrowser = ({ tx, contract }) => {
  // const [loaded, setLoaded] = useState(false);
  const [files, setFiles] = useState([]);

  // useEffect(() => {
  //   const loadFiles = async () => {
  //     const files = await tx(contract.retreiveOwnedFiles());
  //     setFiles(files.map(file => JSON.parse(ethers.utils.parseBytes32String(file))));
  //     setLoaded(true);
  //   }
  //   loadFiles();
  // }, [loaded]);

  const handleCreateFolder = async key => {
    // Make smart contract call
    await tx(contract.addFolder(key));

    // setFiles(_files => {
    //   _files = _files.concat([
    //     {
    //       key: key,
    //     },
    //   ]);
    //   return _files;
    // });
  };
  const handleCreateFiles = (files, prefix) => {
    setFiles(_files => {
      const newFiles = files.map(file => {
        let newKey = prefix;
        if (prefix !== "" && prefix.substring(prefix.length - 1, prefix.length) !== "/") {
          newKey += "/";
        }
        newKey += file.name;
        return {
          key: newKey,
          size: file.size,
          modified: +Moment(),
        };
      });

      const uniqueNewFiles = [];
      newFiles.map(newFile => {
        let exists = false;
        _files.map(existingFile => {
          if (existingFile.key === newFile.key) {
            exists = true;
          }
        });
        if (!exists) {
          uniqueNewFiles.push(newFile);
        }
      });
      _files = _files.concat(uniqueNewFiles);
      return _files;
    });
  };
  const handleRenameFolder = (oldKey, newKey) => {
    setFiles(_files => {
      const newFiles = [];
      _files.map(file => {
        if (file.key.substr(0, oldKey.length) === oldKey) {
          newFiles.push({
            ...file,
            key: file.key.replace(oldKey, newKey),
            modified: +Moment(),
          });
        } else {
          newFiles.push(file);
        }
      });
      _files = newFiles;
      return _files;
    });
  };
  const handleRenameFile = (oldKey, newKey) => {
    setFiles(_files => {
      const newFiles = [];
      _files.map(file => {
        if (file.key === oldKey) {
          newFiles.push({
            ...file,
            key: newKey,
            modified: +Moment(),
          });
        } else {
          newFiles.push(file);
        }
      });
      _files = newFiles;
      return _files;
    });
  };
  const handleDeleteFolder = folderKey => {
    setFiles(_files => {
      const newFiles = [];
      _files.map(file => {
        if (file.key.substr(0, folderKey.length) !== folderKey) {
          newFiles.push(file);
        }
      });
      _files = newFiles;
      return _files;
    });
  };
  const handleDeleteFile = fileKey => {
    setFiles(_files => {
      const newFiles = [];
      _files.map(file => {
        if (file.key !== fileKey) {
          newFiles.push(file);
        }
      });
      _files = newFiles;
      return _files;
    });
  };

  const loadFiles = async () => {
    const files = await tx(contract.retreiveOwnedFiles());
    setFiles(
      files[0].map((key, index) => {
        return {
          key: key,
          ipfsHash: files[1][index],
          size: files[2][index],
          modified: Moment(new Date(files[3][index])),
        };
      }),
    );
  }

  return (
    <>
      <Button
        type={"primary"}
        // loading={true}
        onClick={loadFiles}
      >
        Load Files
      </Button>
      <FileBrowser
        files={files}
        icons={Icons.FontAwesome(4)}
        onCreateFolder={handleCreateFolder}
        onCreateFiles={handleCreateFiles}
        onMoveFolder={handleRenameFolder}
        onMoveFile={handleRenameFile}
        onRenameFolder={handleRenameFolder}
        onRenameFile={handleRenameFile}
        onDeleteFolder={handleDeleteFolder}
        onDeleteFile={handleDeleteFile}
      />
    </>
  );
};
