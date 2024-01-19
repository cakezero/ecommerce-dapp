require('dotenv').config();
require('@nomicfoundation/hardhat-toolbox');
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.20",
  networks : {
    sepolia: {
      url: process.env.ALCHEMY_SEPOLIA_URL,
      accounts: [process.env.SEPOLIA_PRIVATE_KEY]
    }
  }
};
