import React, { useState } from "react";
import Moment from "moment";
import "font-awesome/css/font-awesome.min.css";

import FileBrowser, { Icons } from "react-keyed-file-browser";
import { Button } from "antd";

const SharedWithMe = ({ tx, contract }) => {
  const [files, setFiles] = useState([]);

  const loadFiles = async () => {
    const files = await tx(contract.retreiveFilesSharedWithMe());
    console.log("Files loaded ==> ", files);

    setFiles(
      files[0].map((id, index) => {
        return {
          id,
          key: files[1][index],
          ipfsHash: files[2][index],
          size: files[3][index],
          modified: +Moment(files[4][index] * 1000),
          visibility: files[5][index],
        };
      }),
    );
  };

  return (
    <>
<<<<<<< HEAD
<<<<<<< HEAD
      <Button type={"primary"} onClick={loadFiles}>
=======
      <Button type={"primary"} style={{ marginTop: 10, marginBottom: 10 }} onClick={loadFiles}>
>>>>>>> 2bf4b6fb1cb9c033b53f5feb81620e35cc9b9c60
=======
      <Button type={"primary"} style={{ marginTop: 10, marginBottom: 10 }} onClick={loadFiles}>
>>>>>>> 01e46dacad130137bf4c056dc952b2ea9b05e43b
        Load Files
      </Button>{" "}
      &nbsp;
      <FileBrowser files={files} icons={Icons.FontAwesome(4)} />
    </>
  );
};

export default SharedWithMe;
