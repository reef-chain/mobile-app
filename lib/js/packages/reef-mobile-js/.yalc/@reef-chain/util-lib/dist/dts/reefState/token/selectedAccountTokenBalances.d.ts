import { Token, TokenBalance } from "../../token/tokenModel";
import { BigNumber } from "ethers";
import { Observable } from "rxjs";
import { StatusDataObject } from "../model/statusDataObject";
import { ReefAccount } from "../../account/accountModel";
import { AxiosInstance } from "axios";
export declare const fetchTokensData: (httpClient: any, missingCacheContractDataAddresses: string[]) => Observable<Token[]>;
export declare const replaceReefBalanceFromAccount: (tokens: StatusDataObject<StatusDataObject<Token | TokenBalance>[]>, accountBalance: BigNumber | null | undefined) => StatusDataObject<StatusDataObject<Token | TokenBalance>[]>;
export declare const loadAccountTokens_sdo: ([httpClient, signer, forceReloadj, tokensUpdated,]: [AxiosInstance, StatusDataObject<ReefAccount>, any, any]) => Observable<StatusDataObject<StatusDataObject<Token | TokenBalance>[]>>;
export declare const setReefBalanceFromAccount: ([tokens, selSigner]: [
    StatusDataObject<StatusDataObject<Token | TokenBalance>[]>,
    StatusDataObject<ReefAccount> | undefined
]) => StatusDataObject<StatusDataObject<Token | TokenBalance>[]>;
