const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("IPFS", function () {
  let alphaShare;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("AlphaShare", function () {
    it("Should deploy AlphaShare", async function () {
      const AlphaShare = await ethers.getContractFactory("AlphaShare");

      alphaShare = await AlphaShare.deploy();
    });

    describe("setPurpose()", function () {
      it("Should be able to set a new purpose", async function () {
        const newPurpose = "Test Purpose";

        await alphaShare.setPurpose(newPurpose);
        expect(await alphaShare.purpose()).to.equal(newPurpose);
      });

      it("Should emit a SetPurpose event ", async function () {
        const [owner] = await ethers.getSigners();

        const newPurpose = "Another Test Purpose";

        expect(await alphaShare.setPurpose(newPurpose))
          .to.emit(alphaShare, "SetPurpose")
          .withArgs(owner.address, newPurpose);
      });
    });
  });
});
