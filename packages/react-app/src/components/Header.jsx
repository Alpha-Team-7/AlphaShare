import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header({ title, subTitle }) {
  return (
    <a target="_blank" rel="noopener noreferrer">
      <PageHeader title={title} subTitle={subTitle} style={{ cursor: "pointer" }} />
    </a>
  );
}

Header.defaultProps = {
  title: "AlphaShare",
  subTitle: "A Decentralized file storage service",
};
