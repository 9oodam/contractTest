const hre = require("hardhat");

async function main() {
  const name = "BounsToken";
  const symbol = "BNC";

  const Token = await hre.ethers.getContractFactory("ERC20");
  console.log(`Deploying ${name}\(\$${symbol})`);

  const token = await Token.deploy(name, symbol);
  await token.deployed();

  console.log(`${name} deployed to:`, token.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
