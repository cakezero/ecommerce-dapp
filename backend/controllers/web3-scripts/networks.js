require('dotenv').config();

const DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS = 2;

const networks = {
    polygonMumbai: {
        gasPrice: 20_000_000_000,
        nonce: undefined,
        accounts: [process.env.SEPOLIA_PRIVATE_KEY],
        verifyApiKey: process.env.POLYGONSCAN_API_KEY || "UNSET",
        chainId: 80001,
        confirmations: DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
        nativeCurrencySymbol: "MATIC",
        linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
        linkPriceFeed: "0x12162c3E810393dEC01362aBf156D7ecf6159528", // LINK/MATIC
        functionsRouter: "0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C",
        donId: "fun-polygon-mumbai-1",
        gatewayUrls: [
        "https://01.functions-gateway.testnet.chain.link/",
        "https://02.functions-gateway.testnet.chain.link/",
        ]
    }
}

module.exports = networks