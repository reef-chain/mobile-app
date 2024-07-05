import { StatusDataObject } from "../model/statusDataObject";
import { Token, TokenBalance, TokenWithAmount } from "../../token/tokenModel";
import { Pool } from "../../token/pool";
export declare const toPlainString: (num: number) => string;
export declare const sortReefTokenFirst: (tokens: StatusDataObject<Token | TokenBalance>[]) => StatusDataObject<Token | TokenBalance>[];
export declare const toTokensWithPrice_sdo: ([tokens, reefPrice, pools]: [
    StatusDataObject<StatusDataObject<Token | TokenBalance>[]>,
    StatusDataObject<number>,
    StatusDataObject<StatusDataObject<Pool | null>[]>
]) => StatusDataObject<StatusDataObject<TokenWithAmount>[]>;
