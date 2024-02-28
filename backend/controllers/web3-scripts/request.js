const { Contract } = require("ethers");
const fs = require("fs");
const path = require("path");
const subsId = process.env.SUBS_ID;
const donId = process.env.DON_ID;
const contractAddress = process.env.CONTRACT_ADDRESS;

const { signer } = require("./connection");
const { abi } = require("../../../smart-contract/abi/EsContract.json");

const EsContract = new Contract(contractAddress, abi, signer);

const source = fs
  .readFileSync(path.resolve(__dirname, "./source.js"))
  .toString();

const gasLimit = 300_000;

console.log("\n Sending request...");
const requestTx = await EsContract.requestPayment(
  source,
  subsId,
  gasLimit,
  donId
);
