import React, { useState } from "react";
import Moment from "moment";
import "font-awesome/css/font-awesome.min.css";

import FileBrowser, { Icons } from "react-keyed-file-browser";
import { Button } from "antd";
export const NestedEditableFileBrowser = ({ tx, contract }) => {
  const [files, setFiles] = useState([]);

  const handleCreateFolder = async key => {
    // Make smart contract call
    const createFolderTx = await tx(contract.addFolder(key));
    await createFolderTx.wait();

    alert("done");

    setFiles(_files => {
      _files = _files.concat([
        {
          key: key,
        },
      ]);

      console.log(_files);
      return _files;
    });
  };
  const handleCreateFiles = (_files, prefix) => {
    const newFiles = _files.map(file => {
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

    // upload Files to IPFS

    const uniqueNewFiles = [];
    newFiles.map(newFile => {
      let exists = false;
      files.map(existingFile => {
        if (existingFile.key === newFile.key) {
          exists = true;
        }
        return null;
      });
      if (!exists) {
        uniqueNewFiles.push(newFile);
      }
      return null;
    });

    setFiles(prev => {
      prev = prev.concat(uniqueNewFiles);
      return prev;
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
  const handleShareFile = fileKey => {
    alert("came hrer to share file");
    console.log(fileKey);
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
  };

  return (
    <>
      <Button type={"primary"} onClick={loadFiles}>
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
        onDeleteFile={handleShareFile}
      />
    </>
  );
};
