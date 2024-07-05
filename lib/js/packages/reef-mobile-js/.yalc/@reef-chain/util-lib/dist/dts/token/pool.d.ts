import { Token, TokenBalance } from "./tokenModel";
import { BigNumber } from "ethers";
export interface Pool {
    token1: Token | TokenBalance;
    token2: Token | TokenBalance;
    decimals: number;
    reserve1: string;
    reserve2: string;
    totalSupply: string;
    poolAddress: string;
    userPoolBalance: string;
}
export interface AvailablePool extends Omit<Pool, "reserve1" | "reserve2" | "userPoolBalance"> {
    totalVolumeToken1: BigNumber;
    totalVolumeToken2: BigNumber;
    lastTimeframe: string;
    reserve1?: string;
    reserve2?: string;
    userPoolBalance?: string;
}
