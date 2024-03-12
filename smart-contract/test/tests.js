const { expect } = require("chai");
const hre = require("hardhat");

const { CCIP_ROUTER, CHAIN_SELECTOR, USDC_CONTRACT, LINK_TOKEN } = process.env;

describe("EsContract", function () {
  it("should generateId", async function () {
    const crow = await ethers.deployContract(
      "EsContract",
      CCIP_ROUTER,
      USDC_CONTRACT,
      CHAIN_SELECTOR,
      LINK_TOKEN
    );
    const id = crow.generateId();

   console.log(id);

    expect(id).to.equal(1);
  });
});
