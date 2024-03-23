require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://rpc.sepolia.org`,
      accounts: [""],
    },
    polygonEVM: {
      url: `https://rpc.ankr.com/polygon_zkevm`,
      accounts: [""],
    },
    linea: {
      url: `https://linea.decubate.com`,
      accounts: [""],
    },
  },
};
