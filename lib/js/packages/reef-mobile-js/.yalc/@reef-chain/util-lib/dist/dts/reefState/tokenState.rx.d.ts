import { Observable } from "rxjs";
import { NFT, Token, TokenBalance, TokenTransfer, TokenWithAmount } from "../token/tokenModel";
import { Pool } from "../token/pool";
import { StatusDataObject } from "./model/statusDataObject";
export declare const selectedTokenBalances_status$: Observable<StatusDataObject<StatusDataObject<Token | TokenBalance>[]>>;
export declare const selectedPools_status$: Observable<StatusDataObject<StatusDataObject<Pool | null>[]>>;
export declare const selectedTokenPrices_status$: Observable<StatusDataObject<StatusDataObject<TokenWithAmount>[]>>;
export declare const selectedNFTs_status$: Observable<StatusDataObject<StatusDataObject<NFT>[]>>;
export declare const selectedTransactionHistory_status$: Observable<StatusDataObject<TokenTransfer[]>>;
