import { task } from "hardhat/config";

task("sub-wrapped-nft-impl-deploy", "cmd deploy wrapped nft").setAction(async (_, { ethers }) => {
  const WrappedHashi721 = await ethers.getContractFactory("WrappedHashi721");
  const wrappedHashi721 = await WrappedHashi721.deploy();
  await wrappedHashi721.deployed();
  console.log("Deployed to: ", wrappedHashi721.address);
  return wrappedHashi721.address;
});