import { Signer } from "@reef-chain/evm-provider";
import { Token, TokenBalance } from "../token/tokenModel";
import { Pool } from "../token/pool";
import { Observable } from "rxjs";
import { StatusDataObject } from "../reefState/model/statusDataObject";
export declare const loadPool: (token1: Token | TokenBalance, token2: Token, signer: Signer, factoryAddress: string) => Promise<Pool>;
export declare const fetchPools$: (tokens: StatusDataObject<Token | TokenBalance>[], signer: Signer, factoryAddress: string) => Observable<StatusDataObject<Pool | null>[]>;
