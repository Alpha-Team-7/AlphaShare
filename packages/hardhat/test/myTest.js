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


     

      // it("Should emit a SetPurpose event ", async function () {
      //   const [owner] = await ethers.getSigners();

      //   const newPurpose = "Another Test Purpose";

      //   expect(await alphaShare.setPurpose(newPurpose))
      //     .to.emit(alphaShare, "SetPurpose")
      //     .withArgs(owner.address, newPurpose);
      // });
    });
  });
});
