require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require('dotenv').config()

let mnemonic = process.env.MNEMONIC;

const infuraNetwork = (network, chainId, gas) => {
  return {
    url: `https://${network}.infura.io/v3/${process.env.PROJECT_ID}`,
    chainId,
    gas,
    accounts: mnemonic ? { mnemonic } : undefined
  };
};

module.exports = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        runs: 999999,
        enabled: true
      }
    }
  },
  networks: {
    hardhat: mnemonic ? { accounts: { mnemonic } } : {},
    local: {
      url: "http://localhost:8545",
      accounts: mnemonic ? { mnemonic } : undefined
    },
    rinkeby: infuraNetwork("rinkeby", 4, 6283185),
    kovan: infuraNetwork("kovan", 42, 6283185),
    goerli: infuraNetwork("goerli", 5, 6283185),
    mumbai: {
      url: "https://rpc-mumbai.matic.today",
      chainId: 80001,
      accounts: mnemonic ? { mnemonic } : undefined
    },
    bsc_testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      accounts: mnemonic ? { mnemonic } : undefined
    }
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 1,
    coinmarketcap: '54bc5f85-604c-4fc7-83d0-861f37e18427'
  }
};

