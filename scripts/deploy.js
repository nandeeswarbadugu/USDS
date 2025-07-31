const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  // Deploy logic contract
  const USDSV1 = await ethers.getContractFactory("USDSV1");
  const usdsLogic = await USDSV1.deploy();
  await usdsLogic.deployed();
  console.log("USDS Logic deployed to:", usdsLogic.address);

  // Deploy proxy
  const Proxy = await ethers.getContractFactory("USDSProxy");
  const proxy = await Proxy.deploy(usdsLogic.address);
  await proxy.deployed();
  console.log("USDS Proxy deployed to:", proxy.address);

  // Call initialize via proxy
  
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
