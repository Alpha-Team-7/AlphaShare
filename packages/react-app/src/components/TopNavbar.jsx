import { Menu } from 'antd';
import { FolderOutlined, FolderAddOutlined, ShareAltOutlined, SortAscendingOutlined, SortDescendingOutlined, DownSquareOutlined} from '@ant-design/icons';
import React, {useEffect, useState } from "react";


const { SubMenu } = Menu;

export default function TopNavbar() {
  const [state, setState] = useState('upload');

let handleClick = e => {
    console.log('click ', e);
    setState(e.key);
  };

    return (
      <Menu onClick={handleClick} selectedKeys={state} mode="horizontal">
        <Menu.Item key="folder" icon={<FolderOutlined />}>
          New Folder
        </Menu.Item>
        <Menu.Item key="upload" icon={<FolderAddOutlined />}>
          Upload Content
        </Menu.Item>
        <Menu.Item key="sharedByMe" icon={<ShareAltOutlined />}>
          Shared By Me
        </Menu.Item>
        <Menu.Item key="sharedWithMe" icon={<ShareAltOutlined />}>
          Shared With Me
        </Menu.Item>
        <Menu.Item key="sortUp" icon={<SortAscendingOutlined />}>
        </Menu.Item>
        <Menu.Item key="sortDown" icon={<SortDescendingOutlined />}>
        </Menu.Item>
        <SubMenu key="SubMenu" icon={<DownSquareOutlined />} title="Sort By">
            <Menu.Item key="setting:1">Name</Menu.Item>
            <Menu.Item key="setting:2">File Size</Menu.Item>
            <Menu.Item key="setting:3">Date Created</Menu.Item>
        </SubMenu>
      </Menu> 
    );
}