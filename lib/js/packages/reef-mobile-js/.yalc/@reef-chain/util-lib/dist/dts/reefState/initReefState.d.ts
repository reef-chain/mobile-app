import { RpcConfig } from "./networkState";
import { Network } from "../network/network";
import { InjectedAccountWithMeta } from "@polkadot/extension-inject/types";
import { InjectedAccountWithMeta as InjectedAccountWithMetaReef, AccountJson } from "../extension";
import { Signer as InjectedSigningKey } from "@polkadot/api/types";
import { IpfsUrlResolverFn } from "./ipfsUrlResolverFn";
import { ReefscanEventsConnConfig } from "../utils/reefscanEvents";
export interface StateOptions {
    network?: Network;
    extension?: string;
    jsonAccounts?: {
        accounts: AccountJson[] | InjectedAccountWithMeta[] | InjectedAccountWithMetaReef[];
        injectedSigner: InjectedSigningKey;
    };
    ipfsHashResolverFn?: IpfsUrlResolverFn;
    reefscanEventsConfig?: ReefscanEventsConnConfig;
    rpcConfig?: RpcConfig;
}
export declare const initReefState: ({ network, extension, jsonAccounts, ipfsHashResolverFn, reefscanEventsConfig, rpcConfig, }: StateOptions) => void;
