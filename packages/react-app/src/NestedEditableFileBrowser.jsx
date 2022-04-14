import React, { useState } from "react";
import Moment from "moment";

import FileBrowser, { Icons } from "react-keyed-file-browser";

export const NestedEditableFileBrowser = ({ tx, contract }) => {
  const [files, setFiles] = useState([
    {
      key: "photos/animals/cat in a hat.png",
      modified: +Moment().subtract(1, "hours"),
      size: 1.5 * 1024 * 1024,
    },
    {
      key: "photos/animals/kitten_ball.png",
      modified: +Moment().subtract(3, "days"),
      size: 545 * 1024,
    },
    {
      key: "photos/monkey/",
      modified: +Moment().subtract(3, "days"),
      size: 545 * 1024,
    },
    {
      key: "photos/animals/elephants.png",
      modified: +Moment().subtract(3, "days"),
      size: 52 * 1024,
    },
    {
      key: "photos/funny fall.gif",
      modified: +Moment().subtract(2, "months"),
      size: 13.2 * 1024 * 1024,
    },
    {
      key: "photos/holiday.jpg",
      modified: +Moment().subtract(25, "days"),
      size: 85 * 1024,
    },
    {
      key: "documents/letter chunks.doc",
      modified: +Moment().subtract(15, "days"),
      size: 480 * 1024,
    },
    {
      key: "documents/export.pdf",
      modified: +Moment().subtract(15, "days"),
      size: 4.2 * 1024 * 1024,
    },
  ]);

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

  return (
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
  );
};
