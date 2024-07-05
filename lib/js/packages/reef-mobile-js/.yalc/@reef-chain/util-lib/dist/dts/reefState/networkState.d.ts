import { Network } from "../network/network";
import { WsProvider } from "@polkadot/api";
export interface RpcConfig {
    autoConnectMs?: number;
    customWsProvider?: WsProvider;
}
export declare let rpcConfig: RpcConfig;
export declare const ACTIVE_NETWORK_LS_KEY = "reef-app-active-network";
export declare const selectedNetwork$: import("rxjs").Observable<Network>;
export declare const setSelectedNetwork: (network: Network) => void;
export declare const setRpcConfig: (conf: RpcConfig) => void;
