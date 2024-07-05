import { Signer } from "@reef-chain/evm-provider";
import { BigNumber, Contract } from "ethers";
import { ReefSigner } from "../account/accountModel";
import { Token } from "../token/tokenModel";
export declare const checkIfERC20ContractExist: (address: string, signer: Signer) => Promise<{
    name: string;
    symbol: string;
    decimals: number;
} | undefined>;
export declare const getREEF20Contract: (address: string, signer: Signer) => Promise<{
    contract: Contract;
    values: {
        name: string;
        symbol: string;
        decimals: number;
    };
} | null>;
export declare const contractToToken: (tokenContract: Contract, signer: ReefSigner) => Promise<Token>;
export declare const balanceOf: (address: string, balanceAddress: string, signer: Signer) => Promise<BigNumber | null>;
export declare const getReefswapRouter: (address: string, signer: Signer) => Contract;
export declare const getReefswapFactory: (address: string, signer: Signer) => Contract;
