const hardhat = require('hardhat')
const { ethers } = hardhat

async function deploy_higher_swap() {
  const accounts = await ethers.getSigners();
  const owner = accounts[0]

  const contractName = "HigherSwap"
  const contractFactory = await ethers.getContractFactory(contractName, owner)
  const higherSwap = await contractFactory.deploy()
  await higherSwap.waitForDeployment()
  console.log('deployed higherSwap address:', await higherSwap.getAddress());
}

deploy_higher_swap()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
