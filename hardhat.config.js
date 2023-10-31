require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-docgen");

module.exports = {
  solidity: "0.8.20",
  docgen: {
    path: './docs',
    clear: true,
  }
};
