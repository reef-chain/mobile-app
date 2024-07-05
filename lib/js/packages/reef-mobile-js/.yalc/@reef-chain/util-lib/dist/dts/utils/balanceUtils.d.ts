export { toReefBalanceDisplay } from "./utils";
import { BigNumber } from "ethers";
interface TokenBalance {
    symbol?: string;
    decimals?: number;
    price?: number;
}
export declare const formatDisplayBalance: (val: BigNumber | string, fraction?: number, tokenDetails?: TokenBalance) => string;
