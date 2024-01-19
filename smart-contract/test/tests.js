const { expect }  = require("chai");
const { ethers } = require("hardhat");

describe("EsContract", function() {
    it("should generateId", async function() {
        const Crow = await ethers.getContractFactory("EsContract");
        const crow = await Crow.deploy();

        expect(crow.generateId()).to.equal(1);
    });
})
