const hre = require('hardhat');

async function main() {
  const esContract = hre.ethers.deployContract("EsContract", process.env.CCIP_ROUTER, process.env.USDC_CONTRACT, process.env.CHAIN_SELECTOR, process.env.LINK_TOKEN)
}

main().catch((error) => {
  console.log(error);
  process.exitCode = 1;
})