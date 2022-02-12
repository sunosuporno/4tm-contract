require('dotenv').config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const { API_URL, MNEMONIC, POLYGONSCAN_API_KEY, MNEMONIC_DEV, API_URL_DEV } = process.env;

module.exports = {
  networks: {
    development: {
      provider: () => 
      new HDWalletProvider(MNEMONIC_DEV, API_URL_DEV),
      port: 7545, // Standard Ethereum port (default: none)
      network_id: 5777, // Any network (default: none)
    },
    matic: {
      provider: () =>
      new HDWalletProvider( MNEMONIC, API_URL
        // numberOfAddresses: 1,
        // shareNonce: true,
      ),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      // gasPrice: 10e9
    },
  },
  compilers: {
    solc: {
      version: "^0.8.10",
      parser: "solcjs",
    },
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    polygonscan: POLYGONSCAN_API_KEY
  }
};

//sudo truffle compile

// sudo truffle migrate --network matic

//sudo truffle run verify Mint4TheMetaverse@{contractAddress} --network matic