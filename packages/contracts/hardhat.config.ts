import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "./tasks/deploy";
import "./tasks/register";
import "./tasks/sub-bridge-deploy";
import "./tasks/sub-bridge-register";
import "./tasks/sub-executor-deploy";
import "./tasks/sub-handler-deploy";
import "./tasks/sub-wrapped-721-deploy";
import "./tasks/verify";

import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";

import networks from "./networks.json";

dotenv.config();

const accounts = process.env.DEPLOYER_PRIVATE_KEY !== undefined ? [process.env.DEPLOYER_PRIVATE_KEY] : [];
const ethersanApiKey = process.env.ETHERSCAN_API_KEY || "";

const config: HardhatUserConfig = {
  solidity: "0.8.15",
  networks: {
    hardhat: process.env.FORK_RINKEBY
      ? {
          forking: {
            url: networks["4"].rpc,
          },
        }
      : {},
    rinkeby: {
      chainId: 4,
      url: networks["4"].rpc,
      accounts,
    },
    goerli: {
      chainId: 5,
      url: networks["5"].rpc,
      accounts,
    },
  },
  typechain: {
    outDir: "./types/typechain",
  },
  etherscan: {
    apiKey: {
      rinkeby: ethersanApiKey,
      goerli: ethersanApiKey,
    },
  },
};

export default config;
