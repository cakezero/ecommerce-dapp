require('dotenv').config();

const { providers, Wallet } = require("ethers");

const RPC_URL = process.env.ALCHEMY_SEPOLIA_URL;

if (!RPC_URL) {
  throw new Error("Please set the RPC_URL environment variable");
}

const provider = new providers.JsonRpcProvider(RPC_URL);
const wallet = new Wallet(process.env.SEPOLIA_PRIVATE_KEY || "UNSET");
const signer = wallet.connect(provider);

module.exports = { provider, wallet, signer };
