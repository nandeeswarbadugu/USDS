const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("USDS (Proxy)", function () {
  let proxy, logic, proxyAsUSDS, owner;

  beforeEach(async () => {
    [owner] = await ethers.getSigners();

    const Logic = await ethers.getContractFactory("USDSV1");
    logic = await Logic.deploy();
    await logic.deployed();

    const Proxy = await ethers.getContractFactory("USDSProxy");
    proxy = await Proxy.deploy(logic.address);
    await proxy.deployed();

    proxyAsUSDS = await ethers.getContractAt("USDSV1", proxy.address);
    await proxyAsUSDS.initialize("USDS Token", "USDS", 6, ethers.utils.parseUnits("1000000", 6));
  });

  it("should initialize correctly", async () => {
    expect(await proxyAsUSDS.name()).to.equal("USDS Token");
    expect(await proxyAsUSDS.symbol()).to.equal("USDS");
    expect(await proxyAsUSDS.totalSupply()).to.equal(ethers.utils.parseUnits("1000000", 6));
  });

  it("should allow transfers", async () => {
    const [, user] = await ethers.getSigners();
    await proxyAsUSDS.transfer(user.address, ethers.utils.parseUnits("1000", 6));
    expect(await proxyAsUSDS.balanceOf(user.address)).to.equal(ethers.utils.parseUnits("1000", 6));
  });
});
