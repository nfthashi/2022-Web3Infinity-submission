import { ethers } from "ethers";
import type { NextApiRequest, NextApiResponse } from "next";

import { isChainId } from "../../../../../shared/types/network";
import { getNFTs } from "../../../lib/moralis";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { chainId, address } = req.query;
  if (typeof address !== "string" || !ethers.utils.isAddress(address)) {
    return res.status(400).json({ error: "address is invalid" });
  }
  if (typeof chainId !== "string" || !isChainId(chainId)) {
    return res.status(400).json({ error: "network is invalid" });
  }
  const nfts = await getNFTs(chainId, address);
  res.status(200).json(nfts);
}