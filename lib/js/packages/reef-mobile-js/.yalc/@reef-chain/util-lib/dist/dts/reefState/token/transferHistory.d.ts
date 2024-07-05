import { TokenTransfer } from "../../token/tokenModel";
import { ReefAccount } from "../../account/accountModel";
import { Observable } from "rxjs";
import { Network } from "../../network/network";
import { StatusDataObject } from "../model/statusDataObject";
import { Provider } from "@reef-chain/evm-provider";
import { AxiosInstance } from "axios";
export declare const loadTransferHistory: ([httpClient, account, network, provider, forceReload, anyBalanceUpdate,]: [
    AxiosInstance,
    StatusDataObject<ReefAccount>,
    Network,
    Provider,
    boolean,
    boolean
]) => Observable<TokenTransfer[]>;
