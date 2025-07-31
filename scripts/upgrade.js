const { ethers } = require("hardhat");

async function main() {
  const [admin] = await ethers.getSigners();

  const proxyAddress = "<PROXY_ADDRESS>";
  const NewVersion = await ethers.getContractFactory("USDSV1");
  const newImpl = await NewVersion.deploy();
  await newImpl.deployed();

  console.log("New logic deployed to:", newImpl.address);

  const proxy = await ethers.getContractAt("USDSProxy", proxyAddress);
  await proxy.connect(admin).upgradeTo(newImpl.address);
  console.log("Proxy upgraded");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
