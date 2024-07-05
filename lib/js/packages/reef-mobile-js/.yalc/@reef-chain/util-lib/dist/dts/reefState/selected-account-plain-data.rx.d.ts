import { Observable } from "rxjs";
import { NFT, Token, TokenBalance, TokenTransfer, TokenWithAmount } from "../token";
import { ReefAccount } from "../account";
export declare const accounts$: Observable<ReefAccount[] | null | undefined>;
export declare const selectedAccount$: Observable<ReefAccount | undefined | null>;
export declare const selectedTokenBalances$: Observable<(Token | TokenBalance)[] | null | undefined>;
export declare const selectedNFTs$: Observable<NFT[] | null | undefined>;
export declare const selectedTokenPrices$: Observable<TokenWithAmount[] | null | undefined>;
export declare const selectedTransactionHistory$: Observable<TokenTransfer[] | null | undefined>;
