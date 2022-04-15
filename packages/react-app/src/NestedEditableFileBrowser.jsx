import React, { useEffect, useState } from "react";
import Moment from "moment";
import "font-awesome/css/font-awesome.min.css";

import FileBrowser, { Icons } from "react-keyed-file-browser";
import { Button, Popconfirm, Modal, Form, Input } from "antd";
import { MinusCircleOutlined, PlusOutlined } from "@ant-design/icons";
import { addToIPFS } from "./helpers/ipfs";

const { ethers } = require("ethers");

export const NestedEditableFileBrowser = ({ tx, contract }) => {
  const [uploadVisibility, setUploadVisibility] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [uploadedFiles, setUploadedFiles] = useState([]);
  const [showPopupForToggleVisibility, setShowPopupForToggleVisibility] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [shareOrUnshareAddresses, setShareOrUnshareAddresses] = useState([]);
  const [unSharing, setUnsharing] = useState(false);
  const [keyOfFileToUnshare, setkeyOfFileToUnshare] = useState("");

  const [form] = Form.useForm();

  useEffect(() => {
    form.setFieldsValue({ addresses: shareOrUnshareAddresses });
  }, [form, shareOrUnshareAddresses]);

  const showModal = () => {
    setIsModalVisible(true);
  };

  const handleOk = () => {
    setIsModalVisible(false);
  };

  const handleCancel = () => {
    setIsModalVisible(false);
  };

  const [files, setFiles] = useState([]);

  const handleCreateFolder = async key => {
    alert("came here to create folder");
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

  // Currently handles one file but can be extended to handle multiple
  const handleCreateFiles = async (_files, prefix) => {
    if (_files.length > 1) {
      alert("we handle only single files for now ");
      return;
    }
    let newKey = prefix;
    if (prefix !== "" && prefix.substring(prefix.length - 1, prefix.length) !== "/") {
      newKey += "/";
    }
    newKey += _files[0].name;

    // Check if key is unique
    let exists = false;
    files.map(existingFile => {
      if (existingFile.key === newKey) {
        exists = true;
      }
      return null;
    });
    if (exists) {
      alert("File Exists");
      return;
    }

    const uploadedFile = await addToIPFS(_files[0]);

    setUploadedFiles([
      {
        key: newKey,
        size: _files[0].size,
        ipfsHash: uploadedFile.path,
      },
    ]);

    setUploading(true);
    setShowPopupForToggleVisibility(true);
  };

  const continueCreateFiles = async () => {
    const uniqueNewFilesKeys = [];
    const uniqueNewFilesIpfsHashes = [];
    const uniqueNewFilesSizes = [];

    uploadedFiles.map(newFile => {
      uniqueNewFilesKeys.push(newFile.key);
      uniqueNewFilesIpfsHashes.push(newFile.ipfsHash);
      uniqueNewFilesSizes.push(newFile.size);
      return null;
    });

    // Make smart contract call
    const createFolderTx = await tx(
      contract.addFiles(uniqueNewFilesKeys, uniqueNewFilesIpfsHashes, uniqueNewFilesSizes, uploadVisibility),
    );
    await createFolderTx.wait();

    // setFiles(prev => {
    //   prev = prev.concat(uniqueNewFiles);
    //   return prev;
    // });

    setUploading(false);
    setUploadedFiles([]);
  };

  const handleShareFile = async fileKey => {
    if (shareOrUnshareAddresses.length < 1) {
      alert("No Addresses to share to");

      return;
    }

    let fileIds = [];
    for (let i = 0; i < fileKey.length; i++) {
      fileIds.push(getFileByKey(fileKey[i]).id);
    }
    // Make smart contract call
    const createFolderTx = await tx(contract.startFileShares(fileIds, shareOrUnshareAddresses));
    await createFolderTx.wait();

    setShareOrUnshareAddresses([]);
  };

  const handleUnshareFile = async fileKey => {
    // if (shareOrUnshareAddresses.length < 1) {
    //   alert("No Addresses to unshare from");

    //   return;
    // }
    // Load Already shared addresses
    const sharedWith = await tx(contract.retrieveAddressSharedWith(getFileByKey(fileKey).id));
    console.log("shared with => ", sharedWith);

    setkeyOfFileToUnshare(fileKey);
    setIsModalVisible(true);
    setShareOrUnshareAddresses(sharedWith);

    setUnsharing(true);
  };

  const continueUnsharing = async () => {
    // Make smart contract call
    const createFolderTx = await tx(contract.stopShare(getFileByKey(keyOfFileToUnshare).id, shareOrUnshareAddresses));
    await createFolderTx.wait();

    setShareOrUnshareAddresses([]);
    setUnsharing(false);
    setkeyOfFileToUnshare("");
  };

  const getFileByKey = key => {
    console.log("key==> ", key);

    console.log("current files==> ", files);
    for (let i = 0; i < files.length; i++) {
      if (files[i].key === key) return files[i];
    }
    return null;
  };

  const handleToggleVisibility = async fileKey => {
    alert("toggling visibility");

    let fileIds = [];
    let visibility;
    if (fileKey.length === 1) {
      const file = getFileByKey(fileKey[0]);
      fileIds.push(file.id);
      visibility = !file.visibility;
    } else {
      alert("We handle only single files for now");
      return;
    }
    // Make smart contract call
    const createFolderTx = await tx(contract.updateFilesAccess(fileIds, visibility));
    await createFolderTx.wait();
  };

  const loadFiles = async () => {
    const files = await tx(contract.retreiveOwnedFiles());
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

  const formItemLayout = {
    labelCol: {
      xs: { span: 24 },
      sm: { span: 4 },
    },
    wrapperCol: {
      xs: { span: 24 },
      sm: { span: 20 },
    },
  };

  const onSubmitAddresses = values => {
    const addresses = [];
    if (values.addresses) {
      values.addresses.map(address => {
        addresses.push(address);
        return null;
      });
    }
    setShareOrUnshareAddresses(addresses);
    setIsModalVisible(false);

    if (unSharing) {
      continueUnsharing();
    }
  };

  return (
    <>
      <Button type={"primary"} style={{ marginTop: 10, marginBottom: 10 }} onClick={loadFiles}>
        Load Files
      </Button>{" "}
      &nbsp;
      <Button type={"primary"} style={{ marginTop: 10, marginBottom: 10 }} onClick={() => setIsModalVisible(true)}>
        Addresses for share/unshare
      </Button>
      <Popconfirm
        title="Choose Visibility for upload"
        visible={showPopupForToggleVisibility}
        onConfirm={async () => {
          setUploadVisibility(true);
          setShowPopupForToggleVisibility(false);
          if (uploading) {
            await continueCreateFiles();
          }
        }}
        onCancel={async () => {
          setUploadVisibility(false);
          setShowPopupForToggleVisibility(false);
          if (uploading) {
            await continueCreateFiles();
          }
        }}
        okText="Public"
        cancelText="Private"
      ></Popconfirm>
      <FileBrowser
        files={files}
        icons={Icons.FontAwesome(4)}
        onCreateFolder={handleCreateFolder}
        onCreateFiles={handleCreateFiles}
        onRenameFile={handleUnshareFile}
        onDeleteFile={handleShareFile}
        onDownloadFile={handleToggleVisibility}
      />
      <Modal title="Set up Addresses" visible={isModalVisible} onOk={handleOk} onCancel={handleCancel}>
        <Form form={form} name="dynamic_form_item" onFinish={onSubmitAddresses}>
          <Form.List
            name="addresses"
            rules={[
              {
                validator: async (_, names) => {
                  if (!names || names.length < 1) {
                    return Promise.reject(new Error("At least 1 address"));
                  }
                },
              },
            ]}
          >
            {(fields, { add, remove }, { errors }) => (
              <>
                {fields.map((field, index) => (
                  <Form.Item {...formItemLayout} label={index === 0 ? "" : ""} required={false} key={field.key}>
                    <Form.Item
                      {...field}
                      validateTrigger={["onChange", "onBlur"]}
                      rules={[
                        {
                          required: true,
                          whitespace: true,
                          message: "Please input Address or delete this field.",
                        },
                      ]}
                      noStyle
                    >
                      <Input placeholder="Address of user" style={{ width: "60%" }} />
                    </Form.Item>
                    {fields.length > 1 ? (
                      <MinusCircleOutlined className="dynamic-delete-button" onClick={() => remove(field.name)} />
                    ) : null}
                  </Form.Item>
                ))}
                <Form.Item>
                  <Button type="dashed" onClick={() => add()} style={{ width: "60%" }} icon={<PlusOutlined />}>
                    Add field
                  </Button>
                  <Form.ErrorList errors={errors} />
                </Form.Item>
              </>
            )}
          </Form.List>
          <Form.Item>
            <Button type="primary" htmlType="submit">
              Set
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </>
  );
};
