import { BigNumber } from "ethers";
import { Token, TokenWithAmount } from "../token/tokenModel";
import { Pool } from "../token/pool";
export declare const transformAmount: (decimals: number, amount: string) => string;
export declare const assertAmount: (amount?: string) => string;
export declare const convert2Normal: (decimals: number, inputAmount: string) => number;
interface CalculateAmount {
    decimals: number;
    amount: string;
}
export declare const calculateAmount: ({ decimals, amount, }: CalculateAmount) => string;
export declare const calculateAmountWithPercentage: ({ amount: oldAmount, decimals }: CalculateAmount, percentage: number) => string;
export declare const minimumRecieveAmount: ({ amount }: CalculateAmount, percentage: number) => number;
interface CalculateUsdAmount extends CalculateAmount {
    price: number;
}
export declare const calculateUsdAmount: ({ amount, price, }: CalculateUsdAmount) => number;
export declare const calculateDeadline: (minutes: number) => number;
export declare const calculateBalance: ({ balance, decimals }: Token) => string;
export declare const calculatePoolSupply: (token1: TokenWithAmount, token2: TokenWithAmount, pool?: Pool) => number;
export declare const removeSupply: (percentage: number, supply?: string, decimals?: number) => number;
export declare const removePoolTokenShare: (percentage: number, token?: Token) => string;
export declare const showRemovePoolTokenShare: (percentage: number, token?: Token) => string;
export declare const removeUserPoolSupply: (percentage: number, pool?: Pool) => number;
export declare const convertAmount: (amount: string, fromPrice: number, toPrice: number) => number;
export declare const calculatePoolRatio: (pool?: Pool, first?: boolean) => number;
export declare const calculatePoolShare: (pool?: Pool) => number;
interface ToBalance {
    balance: BigNumber;
    decimals: number;
}
interface ShowBalance extends ToBalance {
    name: string;
    symbol?: string;
}
export declare const showBalance: ({ decimals, balance, name, symbol }: ShowBalance, decimalPoints?: number) => string;
export declare const toBalance: ({ balance, decimals }: ToBalance) => number;
export declare const toUnits: ({ balance, decimals }: ToBalance) => string;
export declare const exponentNrSplit: (numberVal: string) => {
    isExponent: boolean;
    split: string[];
};
export declare const noExponents: (valueNr: string) => string;
export declare const toDecimalPlaces: (value: string, maxDecimalPlaces: number) => string;
export declare const poolRatio: ({ token1, token2 }: Pool) => number;
export declare const ensureAmount: (token: TokenWithAmount) => void;
export declare const getOutputAmount: (token: TokenWithAmount, pool: Pool) => number;
export declare const getInputAmount: (token: TokenWithAmount, pool: Pool) => number;
export declare const calculateImpactPercentage: (sell: TokenWithAmount, buy: TokenWithAmount) => number;
export declare const getHashSumLastNr: (address: string) => number;
export declare const toHumanAmount: (amount: string) => string;
export declare const formatAmount: (amount: number, decimals: number) => string;
export declare const mean: (arr: number[]) => number;
export declare const variance: (arr: number[]) => number;
export declare const std: (arr: number[]) => number;
export declare const checkMinExistentialReefAmount: (token: TokenWithAmount, reefBalance: BigNumber) => {
    valid: boolean;
    message?: string;
    maxTransfer: BigNumber;
};
export declare const ensureTokenAmount: (token: TokenWithAmount) => void;
export declare const ensureExistentialReefAmount: (token: TokenWithAmount, reefBalance: BigNumber) => void;
export {};
