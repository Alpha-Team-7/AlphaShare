const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { add } = require("ramda");

use(solidity);

describe("IPFS", function () {
  let alphaShare;
  let owner, addr1, addr2

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("AlphaShare", function () {
    it("Should deploy AlphaShare", async function () {
      const AlphaShare = await ethers.getContractFactory("AlphaShare");

      alphaShare = await AlphaShare.deploy();

      [owner, addr1, addr2] = await ethers.getSigners()
    });

    describe("addFile() and retrieveFile()", function () {
      it("Add file", async function () {
        await alphaShare.addFiles(["New file"], ["hjklhklijllkjsf"], [34], [true]);
        expect(await alphaShare.fileCounter()).to.equal(2);
     });

     it("retrieve  file", async function () {
        const file = await alphaShare.retrievePublicFiles()
        
        expect(file[1].toString()).to.equal("New file");
        expect(file[2].toString()).to.equal("hjklhklijllkjsf");
     });

     it("set visibility of file", async function () {
        await alphaShare.updateFilesAccess([1], false);

        const file = await alphaShare.retreiveOwnedFiles()

        expect(file[5][0]).to.equal(false);
     });
    });
    describe("Access to file", function () {
      it("should not share if you are not the file owner", async function () {
        await alphaShare.connect(owner).addFiles(["New file"], ["hjklhklijllkjsf"], [34], [true])
       await expect(alphaShare.connect(addr1).startFileShares([1], ["0x6BB12976bdaE76f22D6FFFBD5D1c0125dD566936"])).to.be.revertedWith("You are not the file owner")
      })

      it("should not stop share if you are not the file owner", async function () {
        await alphaShare.connect(owner).addFiles(["New file"], ["hjklhklijllkjsf"], [34], [true])
       await expect(alphaShare.connect(addr1).stopShare(1, ["0x6BB12976bdaE76f22D6FFFBD5D1c0125dD566936"])).to.be.revertedWith("You are not the file owner")
      })
    })
  });
});
